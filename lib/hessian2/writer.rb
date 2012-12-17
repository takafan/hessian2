module Hessian2
  module Writer
    CHUNK_SIZE = 32768

    def call(method, args)
      refs = {}
      out = [ 'H', '2', '0', 'C' ].pack('ahha')
      out << [method.size].pack('n') << method
      out << [args.size].pack('n')
      args.each { |arg| out << write_object(arg, refs) }
      out
    end

    def reply(val)
      out = [ 'H', '2', '0', 'R' ].pack('ahha')
      out << write_object(val)
      out
    end

    def fault(e)
      clbl, mlbl, dlbl = 'code', 'message', 'detail'
      code, message, detail = e.class.to_s, e.message, e.backtrace
      out = [ 'F' ].pack('a')
      out << [ 'H' ].pack('a')
      out << [ clbl.size ].pack('n') << clbl
      out << [ code.size ].pack('n') << write_object(code)
      out << [ mlbl.size ].pack('n') << mlbl
      out << [ message.size ] write_object(message)
      out << [ dlbl.size ].pack('n') << dlbl
      out << write_object(backtrace)
      out << 'Z'
    end

    private
    def write_object(val, refs = {}, chunks = [], type = nil)
      case val
      when TypeWrapper # TODO
        obj, hessian_type = val.object, val.hessian_type
        case hessian_type
        when 'L', 'Long', 'long'  # declare fixnum as long
          [ 'L', obj ].pack('aq>')  # long
        when 'X', 'x' # declare string as xml
          if obj.size > CHUNK_SIZE
            chunk = obj.slice!(0, CHUNK_SIZE)
            if chunk.ascii_only?
              chunks << [ 's', CHUNK_SIZE ].pack('an') << chunk
            else
              chunks << [ 's', CHUNK_SIZE, chunk.unpack('U*') ].flatten.pack('anU*')
            end
            write_object(TypeWrapper.new('X', obj), refs, chunks)
          else
            if obj.ascii_only?
              chunks << [ 'X', obj.size ].pack('an') << obj
            else
              chunks << [ 'X', obj.size, obj.unpack('U*') ].flatten.pack('anU*')
            end
            chunks.join # xml
          end
        when 'B', 'b' # declare string as binary
          if obj.size > CHUNK_SIZE
            chunk = obj.slice!(0, CHUNK_SIZE)
            chunks << [ 'b', CHUNK_SIZE ].pack('an') << chunk
            write_object(TypeWrapper.new('B', obj), refs, chunks)
          else
            chunks << [ 'B', obj.bytesize ].pack('an') << obj
            chunks.join # binary
          end
        else  # type for list, map
          write_object(obj, refs, chunks, hessian_type)
        end
      when TrueClass  # 4.2.  boolean
        'T'           # true
      when FalseClass # 4.2.  boolean
        'F'           # false
      when Time 
        if val.sec == 0
          ["\x4b", val.to_i / 10 ].pack('al>') # 4.3.1.  Compact: date in minutes
        else
          [ "\x4a", val.to_i * 1000 + val.usec / 1000 ].pack('aQ>') # 4.3.  date
        end 
      when Float                      # 4.4.  double
        case val
        when 0                        # 4.4.1.  Compact: double zero
          "\x5b"  
        when 1                        # 4.4.2.  Compact: double one
          "\x5c"  
        when -128..127                # 4.4.3.  Compact: double octet
          [ 'D', val ].pack('ac') 
        when -32768..32767            # 4.4.4.  Compact: double short
          [ 'D', val ].pack('as>')  
        when -2147483648..2147483647  # 4.4.5.  Compact: double float
          [ 'D', val ].pack('al>')  
        else
          [ 'D', val ].pack('aG') 
        end
      when Fixnum             # 4.5.  int
        case val
        when -16..47          # 4.5.1.  Compact: single octet integers
          [ 'I', val ].pack('ac')
        when -2048..2047      # 4.5.2.  Compact: two octet integers
          [ 'I', val ].pack('as>')
        when -262144..262143  # 4.5.3.  Compact: three octet integers
          b2, b2r = val / 65536, val % 65536
          [ 'I', b2, b2r ].pack('acs>')
        else
          [ 'I', val ].pack('al>')  
        end
      when Array  # TODO 4.6.  list
        idx = refs[val.object_id]
        return [ 'R', idx ].pack('aN') if idx

        refs[val.object_id] = refs.size
      
        str = 'V'
        str << 't' << [ type.size, type ].pack('na*') if type
        str << 'l' << [ val.size ].pack('N')
        val.each{ |v| str << write_object(v, refs) }
        str << 'z'  
      when Bignum   # 4.7.  long
        case val
        when -8..15 # 4.7.1.  Compact: single octet longs
          [ 'L', val ].pack('ac')
        when -2048..2047  # 4.7.2.  Compact: two octet longs
          [ 'L', val ].pack('as>')
        when -262144..262143  # 4.7.3.  Compact: three octet longs
          b2, b2r = val / 65536, val % 65536
          [ 'L', b2, b2r ].pack('acs>')
        when -4294967296..4294967295  # 4.7.4.  Compact: four octet longs
          [ 'L', val ].pack('al>')
        else
          [ 'L', val ].pack('aq>')  # long
        end
      when Hash   # TODO 4.8.  map
        idx = refs[val.object_id]
        return [ 'R', idx ].pack('aN') if idx
        
        refs[val.object_id] = refs.size

        str = 'M'
        str << 't' << [ type.size, type ].pack('na*') if type
        val.each do |k, v|
          str << write_object(k, refs)
          str << write_object(v, refs)
        end
        str << 'z'
      when NilClass # 4.9.  null
        'N'
      when String   # 4.12.  string
        if val.size < 32
          val.ascii_only? ? [ val.size ].pack('n') << val : [ val.size, val.unpack('U*') ].flatten.pack('nU*')
        elsif val.size < CHUNK_SIZE
        else

        if val.size > CHUNK_SIZE
          chunk = val.slice!(0, CHUNK_SIZE)
          if chunk.ascii_only?
            chunks << [ 's', CHUNK_SIZE ].pack('an') << chunk
          else
            # unpack-pack if chunk incompatible with ASCII-8BIT
            chunks << [ 's', CHUNK_SIZE, chunk.unpack('U*') ].flatten.pack('anU*')
          end
          write_object(val, refs, chunks)
        else
          if val.ascii_only?
            chunks << [ 'S', val.size ].pack('an') << val
          else
            chunks << [ 'S', val.size, val.unpack('U*') ].flatten.pack('anU*')
          end
          chunks.join # string
        end
      when Symbol
        str = val.to_s
        [ 'S', str.size ].pack('an') << str # string
      
      
      else  # 4.10.  object
        h = {}.tap do |h| 
          val.instance_variables.each {|var| h[var.to_s.delete("@")] = val.instance_variable_get(var) }
        end

        unless type 
          # map ruby module to java package
          arr = val.class.to_s.split('::')
          if arr.size > 1
            klass = arr.pop
            type = arr.map{|m| m.downcase}.join('.') << ".#{klass}"
          else
            type = arr.first
          end
        end

        write_object(h, refs, chunks, type)
      end
    end

  end
end
