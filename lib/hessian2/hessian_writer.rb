module Hessian2
  module HessianWriter
    CHUNK_SIZE = 32768

    def write_call(method, args)
      refs = {}
      out = [ 'c', '0', '1', 'm', method.length ].pack('ahhan') << method
      args.each { |arg| out << write(arg, refs) }
      out << 'z'
    end

    private
    def write(val, refs = {}, chunks = [], type = nil)
      case val
      when TypeWrapper
        obj, hessian_type = val.object, val.hessian_type
        case hessian_type
        when 'L', 'Long', 'long'  # declare as long
          [ 'L', obj ].pack('aq>')  # long
        when 'X', 'x' # declare as xml
          if obj.size > CHUNK_SIZE
            chunk = obj.slice!(0, CHUNK_SIZE)
            if chunk.ascii_only?
              chunks << [ 's', CHUNK_SIZE ].pack('an') << chunk
            else
              chunks << [ 's', CHUNK_SIZE, chunk.unpack('U*') ].flatten.pack('anU*')
            end
            write(TypeWrapper.new('X', obj), refs, chunks)
          else
            if obj.bytesize == obj.size
              chunks << [ 'X', obj.size ].pack('an') << obj
            else
              chunks << [ 'X', obj.size, obj.unpack('U*') ].flatten.pack('anU*')
            end
            chunks.join # xml
          end
        when 'B', 'b' # declare as binary
          [ 'B', obj.size ].pack('an') << obj
          if obj.size > CHUNK_SIZE
            chunk = obj.slice!(0, CHUNK_SIZE)
            chunks << [ 'b', CHUNK_SIZE ].pack('an') << chunk
            write(TypeWrapper.new('B', obj), refs, chunks)
          else
            chunks << [ 'B', obj.size ].pack('an') << obj
            chunks.join # binary
          end
        else  # type for list, map
          write(obj, refs, chunks, hessian_type)
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
        [ 'd', val.to_i * 1000 ].pack('aQ>')  # date
      when String
        if val.size > CHUNK_SIZE
          chunk = val.slice!(0, CHUNK_SIZE)
          if chunk.ascii_only?
            chunks << [ 's', CHUNK_SIZE ].pack('an') << chunk
          else
            # unpack-pack if chunk incompatible with ASCII-8BIT
            chunks << [ 's', CHUNK_SIZE, chunk.unpack('U*') ].flatten.pack('anU*')
          end
          write(val, refs, chunks)
        else
          if val.bytesize == val.size
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
        id = refs[val.object_id]
        return [ 'R', id ].pack('aN') if id

        refs[val.object_id] = refs.size
      
        str = 'V'
        str << 't' << [ type.size, type ].pack('na*') if type
        str << 'l' << [ val.size ].pack('N')
        val.each{ |v| str << write(v, refs) }
        str << 'z'  # list
      when Hash
        id = refs[val.object_id]
        return [ 'R', id ].pack('aN') if id 
        
        refs[val.object_id] = refs.size

        str = 'M'
        str << 't' << [ type.size, type ].pack('na*') if type
        val.each do |k, v|
          str << write(k, refs)
          str << write(v, refs)
        end
        str << 'z'  # map
      else  # covert val to hash
        hash = {}.tap do |h| 
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

        write(hash, refs, chunks, type)
      end
    end

  end
end
