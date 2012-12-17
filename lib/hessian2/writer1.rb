module Hessian2
  module Writer
    CHUNK_SIZE = 32768

    def call(method, args)
      refs = {}
      out = [ 'c', '1', '0', 'm', method.length ].pack('ahhan') << method
      args.each { |arg| out << write_object(arg, refs) }
      out << 'z'
    end

    def reply_value(val)
      out = [ 'r', '1', '0' ].pack('ahh')
      out << write_object(val)
      out << 'z'
    end

    def reply_fault(e)
      out = [ 'r', '1', '0', 'f', 'S', 4 ].pack('ahhaan') << 'code'
      out << write_object(e.class.to_s)
      out << [ 'S', 7 ].pack('an') << 'message'
      out << write_object(e.message)
      out << [ 'S', 6 ].pack('an') << 'detail'
      out << write_object(e.backtrace)
      out << 'z'
    end

    private
    def write_object(val, refs = {}, chunks = [], type = nil)
      case val
      when TypeWrapper
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
      when NilClass
        'N' # null
      when TrueClass
        'T' # true
      when FalseClass
        'F' # false
      when Fixnum
        [ 'I', val ].pack('al>')  # int
      when Bignum
        [ 'L', val ].pack('aq>')  # long
      when Float
        [ 'D', val ].pack('aG') # double
      when Time
        [ 'd', val.to_i * 1000 + val.usec / 1000 ].pack('aQ>')  # date
      when String
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
      when Array
        idx = refs[val.object_id]
        return [ 'R', idx ].pack('aN') if idx

        refs[val.object_id] = refs.size
      
        str = 'V'
        str << 't' << [ type.size, type ].pack('na*') if type
        str << 'l' << [ val.size ].pack('N')
        val.each{ |v| str << write_object(v, refs) }
        str << 'z'  # list
      when Hash
        idx = refs[val.object_id]
        return [ 'R', idx ].pack('aN') if idx
        
        refs[val.object_id] = refs.size

        str = 'M'
        str << 't' << [ type.size, type ].pack('na*') if type
        val.each do |k, v|
          str << write_object(k, refs)
          str << write_object(v, refs)
        end
        str << 'z'  # map
      else  # covert val to hash
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
