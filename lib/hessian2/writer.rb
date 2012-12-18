# com.caucho.hessian.io Hessian2Output
require 'hessian2/constants'

module Hessian2
  module Writer

    def call(method, args)
      refs = {}
      out = [ 'H', '2', '0', 'C' ].pack('ahha')
      out << [method.size].pack('C') << method
      out << [args.size].pack('C')
      args.each { |arg| out << write_val(arg, refs) }
      out
    end

    def reply(val)
      out = [ 'H', '2', '0', 'R' ].pack('ahha')
      out << write_val(val)
      out
    end

    def fault(e)  # TODO
      clbl, mlbl, dlbl = 'code', 'message', 'detail'
      code, message, detail = e.class.to_s, e.message, e.backtrace
      out = [ 'F' ].pack('a')
      out << [ 'H' ].pack('a')
      out << [ clbl.size ].pack('n') << clbl
      out << [ code.size ].pack('n') << write_val(code)
      out << [ mlbl.size ].pack('n') << mlbl
      out << [ message.size ] write_val(message)
      out << [ dlbl.size ].pack('n') << dlbl
      out << write_val(backtrace)
      out << 'Z'
    end

    private
    def write_val(val, refs = {}, type = nil)
      case val
      when TypeWrapper # TODO
        obj, hessian_type = val.object, val.hessian_type
        case hessian_type
        when 'L', 'Long', 'long'  # declare fixnum as long
          [ 'L', obj ].pack('aq>')  # long
        when 'B', 'b' # declare string as binary
          write_binary(val)
        else  # type for list, map
          write_val(obj, refs, hessian_type)
        end
      when TrueClass  # 4.2.  boolean
        'T'           # true
      when FalseClass # 4.2.  boolean
        'F'           # false
      when Time 
        if val.sec == 0
          [ BC_DATE_MINUTE, val.to_i / 10 ].pack('al>') # 4.3.1.  Compact: date in minutes
        else
          [ BC_DATE, val.to_i * 1000 + val.usec / 1000 ].pack('aQ>') # 4.3.  date
        end
      when Float                      # 4.4.  double
        case val
        when 0                        # 4.4.1.  Compact: double zero
          BC_DOUBLE_ZERO  
        when 1                        # 4.4.2.  Compact: double one
          BC_DOUBLE_ONE  
        when -128..127                # 4.4.3.  Compact: double octet
          [ BC_DOUBLE, val ].pack('ac') 
        when -32768..32767            # 4.4.4.  Compact: double short
          [ BC_DOUBLE, val ].pack('as>')  
        when -2147483648..2147483647  # 4.4.5.  Compact: double float
          [ BC_DOUBLE, val ].pack('al>')  
        else
          [ BC_DOUBLE, val ].pack('aG') 
        end
      when Fixnum             # 4.5.  int
        case val
        when INT_DIRECT_MIN..INT_DIRECT_MAX         # 4.5.1.  Compact: single octet integers
          [ val + BC_INT_ZERO ].pack('c')
        when INT_BYTE_MIN..INT_BYTE_MAX      # 4.5.2.  Compact: two octet integers
          [ BC_INT, val ].pack('as>')
        when -262144..262143  # 4.5.3.  Compact: three octet integers
          b2, b2r = val / 65536, val % 65536
          [ BC_INT, b2, b2r ].pack('acs>')
        else
          [ BC_INT, val ].pack('al>')  
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
          [ BC_LONG, val ].pack('ac')
        when -2048..2047  # 4.7.2.  Compact: two octet longs
          [ BC_LONG, val ].pack('as>')
        when -262144..262143  # 4.7.3.  Compact: three octet longs
          b2, b2r = val / 65536, val % 65536
          [ BC_LONG, b2, b2r ].pack('acs>')
        when -4294967296..4294967295  # 4.7.4.  Compact: four octet longs
          [ BC_LONG, val ].pack('al>')
        else
          [ BC_LONG, val ].pack('aq>')  # long
        end
      when Hash   # TODO 4.8.  map
        idx = refs[val.object_id]
        return [ 'R', idx ].pack('aN') if idx
        
        refs[val.object_id] = refs.size

        str = 'M'
        str << 't' << [ type.size, type ].pack('na*') if type
        val.each do |k, v|
          str << write_val(k, refs)
          str << write_val(v, refs)
        end
        str << 'z'
      when NilClass # 4.9.  null
        BC_NULL
      when String   # 4.12.  string
        write_string(val)
      when Symbol
        write_string(val.to_s)
      else  # 4.10.  object
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

        h = {}.tap do |h|
          val.instance_variables.each { |var| h[var.to_s.delete("@")] = val.instance_variable_get(var) }
        end

        str = [ BC_OBJECT_DEF, type.size ].pack('aC') << type
        str << [ h.keys.size ].pack()
        

        write_val(h, refs, type)
      end
    end 

    def write_string(val, chunks = [])
      while val.size > 0x8000 # 32768
        chunk = val.slice!(0, 0x8000)
        if chunk.ascii_only?
          chunks << [ BC_STRING_CHUNK, 0x8000 ].pack('an') << chunk
        else
          # unpack-pack if chunk incompatible with ASCII-8BIT
          chunks << [ BC_STRING_CHUNK, 0x8000, chunk.unpack('U*') ].flatten.pack('anU*')
        end
        write_string(val, chunks)
      end

      if val.size < 32
        if val.ascii_only? 
          chunks << [ val.size ].pack('C') << val 
        else 
          chunks << [ val.size, val.unpack('U*') ].flatten.pack('CU*')
        end
      else
        if val.ascii_only?
          chunks << [ BC_STRING, val.size ].pack('an') << val
        else
          chunks << [ BC_STRING, val.size, val.unpack('U*') ].flatten.pack('anU*')
        end
      end

      chunks.join
    end

    def write_binary(val, chunks = [])
      if val.size > 0x8000
        chunk = val.slice!(0, 0x8000)
        chunks << [ 'b', 0x8000 ].pack('an') << chunk
        write_binary(val, chunks)
      else
        chunks << [ 'B', val.bytesize ].pack('an') << val
      end

      chunks.join
    end

  end
end
