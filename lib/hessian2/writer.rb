require 'hessian2/constants'

module Hessian2
  module Writer
    include Constants

    def call(method, args)
      vrefs, crefs, trefs = {}, {}, {}
      out = [ 'H', '2', '0', 'C' ].pack('ahha')
      out << write_string(method)
      out << write_int(args.size)
      args.each { |arg| out << write_val(arg, vrefs, crefs, trefs) }
      puts out
      out
    end

    def reply(val)
      out = [ 'H', '2', '0', 'R' ].pack('ahha')
      out << write_val(val)
      out
    end

    def write_fault(e)
      val = {
        code: e.class.to_s,
        message: e.message,
        detail: e.backtrace }
      [ 'F' ].pack('a') << write_val(val)
    end

    private
    def write_val(val, vrefs = {}, crefs = {}, trefs = {}, type = nil)
      case val
      when TypeWrapper
        val, type = val.object, val.hessian_type
        case type
        when 'L', 'Long', 'long'  # declare as long
          case val
          when LONG_DIRECT_MIN..LONG_DIRECT_MAX  # single octet longs
            [ BC_LONG_ZERO + val ].pack('c')
          when LONG_BYTE_MIN..LONG_BYTE_MAX  # two octet longs
            [ BC_LONG_BYTE_ZERO + (val >> 8), val ].pack('cc')
          when LONG_SHORT_MIN..LONG_SHORT_MAX  # three octet longs
            [ BC_LONG_SHORT_ZERO + (val >> 16), (val >> 8), val ].pack('ccc')
          when -0x80_000_000..0x7f_fff_fff  # four octet longs
            [ BC_LONG_INT, val ].pack('al>')
          else  # long
            [ BC_LONG, val ].pack('aq>')
          end
        when 'B', 'b' # declare as bin
          write_binary(val)
        else  # declare a class definition for an object, or a type for list/map elements
          write_val(val, vrefs, crefs, trefs, type)
        end
      when TrueClass
        'T'  # true
      when FalseClass
        'F'  # false
      when Time 
        if val.sec == 0  # date in minutes
          [ BC_DATE_MINUTE, val.to_i / 10 ].pack('al>')  
        else
          [ BC_DATE, val.to_i * 1000 + val.usec / 1000 ].pack('aQ>')  # date
        end
      when Float
        return BC_DOUBLE_ZERO if val == 0  # double zero
        return BC_DOUBLE_ONE if val == 1  # double one
        if val.to_i == val
          return [ BC_DOUBLE_BYTE, val ].pack('cc') if (-0x80..0x7f).include?(val)  # double octet
          return [ BC_DOUBLE_SHORT, (val >> 8), val ].pack('ccc') if (-0x8000..0x7fff).include?(val)  # double short
          return [ BC_DOUBLE_MILL, (val >> 24), (val >> 16), (val >> 8), val ].pack('acccc') if (-0x80_000_000..0x7f_fff_fff).include?(val) # double float
        end
        [ BC_DOUBLE, val ].pack('aG')  # double
      when Fixnum
        write_int(val)
      when Array
        idx = vrefs[val.object_id]
        return write_ref(idx) if idx
        vrefs[val.object_id] = vrefs.size  # store a value reference
        
        if type
          if trefs.include?(type)
            tstr = write_int(trefs[type])
          else
            trefs[type] = trefs.size  # store a type
            tstr = write_string(type)
          end

          length = val.size
          if length <= LIST_DIRECT_MAX  # [x70-77] type value*
            str = [ BC_LIST_DIRECT + length ].pack('C')
            str << tstr
          else  # 'V' type int value*
            str = BC_LIST_FIXED
            str << tstr
            str << write_val(length)
          end
        else
          length = val.size
          if length <= LIST_DIRECT_MAX  # [x78-7f] value*
            str = [ BC_LIST_DIRECT_UNTYPED + length ].pack('C')
          else  # x58 int value*
            str = [ BC_LIST_FIXED_UNTYPED ].pack('C')
            str << write_val(length)
          end
        end

        val.each do |v|
          str << write_val(v, vrefs, crefs, trefs)
        end

        str
      when Bignum
        if (-0x80_000_000..0x7f_fff_fff).include?(val)  # four octet longs
          [ BC_LONG_INT, val ].pack('al>')
        else  # long
          [ BC_LONG, val ].pack('aq>')
        end
      when Hash
        idx = vrefs[val.object_id]
        return write_ref(idx) if idx
        vrefs[val.object_id] = vrefs.size  # store a value reference

        if type
          if trefs.include?(type)
            tstr = write_int(trefs[type])
          else
            trefs[type] = trefs.size  # store a type
            tstr = write_string(type)
          end

          str = BC_MAP
          str << tstr
        else
          str = BC_MAP_UNTYPED
        end

        val.each do |k, v|
          str << write_val(k, vrefs, crefs, trefs)
          str << write_val(v, vrefs, crefs, trefs)
        end

        str << BC_END
      when NilClass
        BC_NULL  # null
      when String
        write_string(val)
      when Symbol
        write_string(val.to_s)
      else
        idx = vrefs[val.object_id]
        return write_ref(idx) if idx
        vrefs[val.object_id] = vrefs.size  # store a value reference

        type = val.class.to_s unless type
        vars = val.instance_variables

        if crefs.include?(type)
          ref = crefs[type]
          str = write_int(ref)
        else
          ref = crefs[type] = crefs.size  # store a class definition
          str = BC_OBJECT_DEF << write_string(type) << write_int(vars.size)
          vars.each do |sym|
            str << write_string(sym.to_s[1..-1])
          end
        end

        if crefs[type] <= OBJECT_DIRECT_MAX
          str << [ BC_OBJECT_DIRECT + ref ].pack('C')
        else
          str << BC_OBJECT << write_int(ref)
        end
        
        vars.each do |sym|
          str << write_val(val.instance_variable_get(sym), vrefs, crefs, trefs)
        end

        str
      end
    end

    def write_ref(val)
      BC_REF << write_int(val)
    end

    def write_int(val)
      case val
      when INT_DIRECT_MIN..INT_DIRECT_MAX  # single octet integers
        [ BC_INT_ZERO + val ].pack('c')
      when INT_BYTE_MIN..INT_BYTE_MAX  # two octet integers
        [ BC_INT_BYTE_ZERO + (val >> 8), val ].pack('cc')
      when INT_SHORT_MIN..INT_SHORT_MAX  # three octet integers
        [ BC_INT_SHORT_ZERO + (val >> 16), (val >> 8), val].pack('ccc')
      else  # integer
        [ BC_INT, val ].pack('al>')
      end
    end

    def write_string(val, chunks = [])
      length = val.size
      while length > 0x8000
        chunk = val.slice!(0, 0x8000)
        if chunk.ascii_only?
          chunks << [ BC_STRING_CHUNK, 0x8000 ].pack('an') << chunk
        else
          # unpack-pack if chunk incompatible with ASCII-8BIT
          chunks << [ BC_STRING_CHUNK, 0x8000, chunk.unpack('U*') ].flatten.pack('anU*')
        end
        write_string(val, chunks)
      end

      if length <= STRING_DIRECT_MAX
        if val.ascii_only? 
          chunks << [ BC_STRING_DIRECT + length ].pack('C') << val 
        else 
          chunks << [ BC_STRING_DIRECT + length, val.unpack('U*') ].flatten.pack('CU*')
        end
      elsif length <= STRING_SHORT_MAX
        if val.ascii_only? 
          chunks << [ BC_STRING_SHORT + (length >> 8), length ].pack('CC') << val
        else
          chunks << [ BC_STRING_SHORT + (length >> 8), length, val.unpack('U*') ].flatten.pack('CCU*')
        end
      else
        if val.ascii_only?
          chunks << [ BC_STRING, length ].pack('an') << val
        else
          chunks << [ BC_STRING, length, val.unpack('U*') ].flatten.pack('anU*')
        end
      end

      chunks.join
    end

    def write_binary(val, chunks = [])
      length = val.size
      while length > 0x8000
        chunk = val.slice!(0, 0x8000)
        chunks << [ BC_BINARY_CHUNK, 0x8000 ].pack('an') << chunk
        write_binary(val, chunks)
      end

      if length <= BINARY_DIRECT_MAX
        chunks << [ BC_BINARY_DIRECT + length ].pack('C') << val 
      elsif length <= BINARY_SHORT_MAX
        chunks << [ BC_BINARY_SHORT + (length >> 8), length ].pack('CC') << val
      else
        chunks << [ BC_BINARY, length ].pack('an') << val
      end

      chunks.join
    end

  end
end
