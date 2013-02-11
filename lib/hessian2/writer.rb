require 'hessian2/constants'

module Hessian2
  module Writer
    include Constants

    def call(method, args)
      refs, crefs, trefs = {}, {}, {}
      out = [ 'H', '2', '0', 'C' ].pack('ahha')
      out << write_string(method)
      out << write_int(args.size)
      args.each { |arg| out << write(arg, refs, crefs, trefs) }
      out
    end

    def reply(val)
      [ 'H', '2', '0', 'R' ].pack('ahha') << write(val)
    end

    def write_fault(e)
      val = {
        code: e.class.to_s,
        message: e.message,
        detail: e.backtrace }
      [ 'F' ].pack('a') << write_map(val)
    end

    def write(val, refs = {}, crefs = {}, trefs = {}, wtype = nil, cidx = nil, fmask = {})
      case val
      when ClassWrapper # hash as monkey; monkey as example.monkey; [hash as [monkey; [monkey as [example.monkey
        idx = refs[val.object_id]
        return write_ref(idx) if idx
        obj = val.object
        return write_null if obj.nil?
        refs[val.object_id] = refs.size # store a value reference
        klass = val.hessian_class
        # is_obj_arr = klass[0] == '['
        return [ BC_LIST_DIRECT_UNTYPED ].pack('C') if obj.class == Array and obj.size == 0

        fclass = klass.delete('[]')
        if crefs.include?(fclass)
          cidx = crefs[fclass]
          
          str = ''
        else
          cidx = crefs[fclass] = crefs.size # store a class definition
          if obj.class == Array
            sample = obj.first
            if sample.class == Hash
              vars = sample.keys
            else
              vars = sample.instance_variables.map{|sym| sym.to_s[1..-1]} # skip '@'
            end
          elsif obj.class == Hash
            vars = obj.keys
          else
            vars = obj.instance_variables.map{|sym| sym.to_s[1..-1]} # skip '@'
          end
          fmask[cidx] = vars
          str = [ BC_OBJECT_DEF ].pack('C') << write_string(fclass) << write_int(vars.size)
          vars.each do |var|
            str << write_string(var)
          end
        end

        # if cidx <= OBJECT_DIRECT_MAX
        #   str << [ BC_OBJECT_DIRECT + cidx ].pack('C')
        # else
        #   str << [ BC_OBJECT ].pack('C') << write_int(cidx)
        # end

        # if is_obj_arr
        #   sample = obj.first
        #   if sample.class == Hash
        #     vvals = sample.values
        #   else
        #     vvals = sample.instance_variables.map{|sym| obj.instance_variable_get(sym)}
        #   end
        # elsif obj.class == Hash
        #   vvals = obj.values
        # else
        #   vvals = obj.instance_variables.map{|sym| obj.instance_variable_get(sym)}
        # end

        # vvals.each do |vval|
        #   str << write(vval, refs, crefs, trefs)
        # end
        str << write(obj, refs, crefs, trefs, nil, cidx, fmask)

        str
      when TypeWrapper
        write(val.object, refs, crefs, trefs, val.hessian_type)
      when TrueClass
        [ BC_TRUE ].pack('C')
      when FalseClass
        [ BC_FALSE ].pack('C')
      when Time
        if val.usec == 0 and val.sec == 0 # date in minutes
          [ BC_DATE_MINUTE, val.to_i / 60 ].pack('CL>')
        else
          [ BC_DATE, val.to_i * 1000 + val.usec / 1000 ].pack('CQ>') # date
        end
      when Float
        case val.infinite?
        when 1
          return [ BC_DOUBLE, Float::INFINITY ].pack('CG')
        when -1
          return [ BC_DOUBLE, -Float::INFINITY ].pack('CG')
        else
          return [ BC_DOUBLE, Float::NAN ].pack('CG') if val.nan?
          return [ BC_DOUBLE_ZERO ].pack('C') if val.zero? # double zero
          return [ BC_DOUBLE_ONE ].pack('C') if val == 1 # double one
          ival = val.to_i
          if ival == val
            return [ BC_DOUBLE_BYTE, ival ].pack('Cc') if (-0x80..0x7f).include?(ival) # double octet
            return [ BC_DOUBLE_SHORT, (ival >> 8), ival ].pack('Ccc') if (-0x8000..0x7fff).include?(ival) # double short
          end
          mval = val * 1000
          if mval.finite?
            mills = mval.to_i
            if (-0x80_000_000..0x7f_fff_fff).include?(mills) and 0.001 * mills == val
              [ BC_DOUBLE_MILL, mills ].pack('Cl>') # double mill
            end
          end
          [ BC_DOUBLE, val ].pack('CG') # double
        end
      when Fixnum
        return write_long(val) if wtype and %w[ L Long long ].include?(wtype)
        write_int(val)
      when Array
        write_list()
      when Bignum
        if wtype
          if %w[ I Integer int ].include?(wtype)
            return write_int(val)
          elsif %w[ L Long long ].include?(wtype)
            return write_long(val)
          end
        end
        if (-0x80_000_000..0x7f_fff_fff).include?(val) # four octet longs
          [ BC_LONG_INT, val ].pack('Cl>')
        else # long
          [ BC_LONG, val ].pack('Cq>')
        end
      when Hash
        write_map(val, refs, crefs, cidx, fmask)
      when NilClass
        write_null
      when String
        if wtype 
          if %w[ B b ].include?(wtype)
            chunks, i, len = [], 0, val.size
            while len > 0x8000
              chunks << [ BC_BINARY_CHUNK, 0x8000 ].pack('Cn') << val[i...(i += 0x8000)]
              len -= 0x8000
            end
            final = val[i..-1]
            if len <= BINARY_DIRECT_MAX
              chunks << [ BC_BINARY_DIRECT + len ].pack('C') << final
            elsif len <= BINARY_SHORT_MAX
              chunks << [ BC_BINARY_SHORT + (len >> 8), len ].pack('CC') << final
            else
              chunks << [ BC_BINARY, len ].pack('Cn') << final
            end
            return chunks.join
          elsif %w[ I Integer int ].include?(wtype)
            return write_int(Integer(val))
          elsif %w[ L Long long ].include?(wtype)
            return write_long(Integer(val))
          end
        end
        write_string(val)
      when Symbol
        write_string(val)
      else
        idx = refs[val.object_id]
        return write_ref(idx) if idx
        refs[val.object_id] = refs.size # store a value reference
        unless cidx
          klass = val.class
          if crefs.include?(klass)
            cidx = crefs[klass]
            str = ''
          else
            cidx = crefs[klass] = crefs.size # store a class definition
            vars = val.instance_variables.map{|sym| sym.to_s[1..-1]} # shift '@'
            fmask[cidx] = vars
            str = [ BC_OBJECT_DEF ].pack('C') << write_string(klass) << write_int(vars.size)
            vars.each do |var|
              str << write_string(var)
            end
          end
        end
        if cidx <= OBJECT_DIRECT_MAX
          str << [ BC_OBJECT_DIRECT + cidx ].pack('C')
        else
          str << [ BC_OBJECT ].pack('C') << write_int(cidx)
        end
        fmask[cidx].each do |f|
          str << write(val.instance_variable_get("@#{f}".to_sym), refs, crefs, trefs)
        end
        str
      end
    end

    def print_string(str)
      arr, i = Array.new(str.bytesize), 0
      str.unpack('U*').each do |c|
        if c < 0x80 # 0xxxxxxx
          arr[i] = c
        elsif c < 0x800 # 110xxxxx 10xxxxxx
          arr[i] = 0xc0 + ((c >> 6) & 0x1f)
          arr[i += 1] = 0x80 + (c & 0x3f)
        else # 1110xxxx 10xxxxxx 10xxxxxx
          arr[i] = 0xe0 + ((c >> 12) & 0xf)
          arr[i += 1] = 0x80 + ((c >> 6) & 0x3f)
          arr[i += 1] = 0x80 + (c & 0x3f)
        end
        i += 1
      end
      arr.pack('C*')
    end

    def write_ref(val)
      [ BC_REF ].pack('C') << write_int(val)
    end

    def write_int(val)
      case val
      when INT_DIRECT_MIN..INT_DIRECT_MAX # single octet integers
        [ BC_INT_ZERO + val ].pack('c')
      when INT_BYTE_MIN..INT_BYTE_MAX # two octet integers
        [ BC_INT_BYTE_ZERO + (val >> 8), val ].pack('cc')
      when INT_SHORT_MIN..INT_SHORT_MAX # three octet integers
        [ BC_INT_SHORT_ZERO + (val >> 16), (val >> 8), val].pack('ccc')
      when -0x80_000_000..0x7f_fff_fff # integer
        [ BC_INT, val ].pack('Cl>')
      else
        [ BC_LONG, val ].pack('Cq>')
      end
    end

    def write_long(val)
      case val
      when LONG_DIRECT_MIN..LONG_DIRECT_MAX # single octet longs
        [ BC_LONG_ZERO + val ].pack('c')
      when LONG_BYTE_MIN..LONG_BYTE_MAX # two octet longs
        [ BC_LONG_BYTE_ZERO + (val >> 8), val ].pack('cc')
      when LONG_SHORT_MIN..LONG_SHORT_MAX # three octet longs
        [ BC_LONG_SHORT_ZERO + (val >> 16), (val >> 8), val ].pack('ccc')
      when -0x80_000_000..0x7f_fff_fff # four octet longs
        [ BC_LONG_INT, val ].pack('Cl>')
      else
        [ BC_LONG, val ].pack('Cq>')
      end
    end

    def write_string(val)
      val = val.to_s unless val.class == String
      chunks, i, len = '', 0, val.size
      while len > 0x8000
        chunks << [ BC_STRING_CHUNK, 0x8000 ].pack('Cn') << print_string(val[i, i += 0x8000])
        len -= 0x8000
      end
      final = val[i..-1]
      chunks << if len <= STRING_DIRECT_MAX
        [ BC_STRING_DIRECT + len ].pack('C')
      elsif len <= STRING_SHORT_MAX
        [ BC_STRING_SHORT + (len >> 8), len ].pack('CC')
      else
        [ BC_STRING, len ].pack('Cn')
      end
      chunks << print_string(final)
    end

    def write_list(val, refs = {}, crefs = {}, trefs = {}, wtype = nil)
      idx = refs[val.object_id]
      return write_ref(idx) if idx
      refs[val.object_id] = refs.size # store a value reference
      if wtype
        # if trefs.include?(wtype)
        #   tstr = write_int(trefs[wtype])
        # else
        #   trefs[wtype] = trefs.size # store a type
        #   tstr = write_string(wtype)
        # end
        # len = val.size
        # if len <= LIST_DIRECT_MAX # [x70-77] type value*
        #   str = [ BC_LIST_DIRECT + len ].pack('C') << tstr
        # else  # 'V' type int value*
        #   str = [ BC_LIST_FIXED ].pack('C') << tstr << write_int(len)
        # end

        # store wtyped array as a object array
        klass = wtype.delete('[]')
        if crefs.include?(klass)
          cidx = crefs[klass]
          str = ''
        else
          cidx = crefs[klass] = crefs.size # store a class definition
          vars = val.instance_variables.map{|sym| sym.to_s[1..-1]} # shift '@'
          str = [ BC_OBJECT_DEF ].pack('C') << write_string(klass) << write_int(vars.size)
          vars.each do |var|
            str << write_string(var)
          end
        end
        if cidx <= OBJECT_DIRECT_MAX
          str << [ BC_OBJECT_DIRECT + cidx ].pack('C')
        else
          str << [ BC_OBJECT ].pack('C') << write_int(cidx)
        end
        vvals = val.instance_variables.map{|sym| val.instance_variable_get(sym)}
        vvals.each do |vval|
          str << write(vval, refs, crefs, trefs)
        end

        
      else
        len = val.size
        if len <= LIST_DIRECT_MAX # [x78-7f] value*
          str = [ BC_LIST_DIRECT_UNTYPED + len ].pack('C')
        else  # x58 int value*
          str = [ BC_LIST_FIXED_UNTYPED ].pack('C') << write_int(len)
        end
      end
      val.each do |v|
        str << write(v, refs, crefs, trefs)
      end
      str
    end

    def write_map(val, refs = {}, crefs = {}, cidx = nil, fmask = {})
      idx = refs[val.object_id]
      return write_ref(idx) if idx
      refs[val.object_id] = refs.size # store a value reference
      # if wtype
      #   if trefs.include?(wtype)
      #     tstr = write_int(trefs[wtype])
      #   else
      #     trefs[wtype] = trefs.size # store a type
      #     tstr = write_string(wtype)
      #   end
      #   str = [ BC_MAP ].pack('C') << tstr
      # else
      #   str = [ BC_MAP_UNTYPED ].pack('C')
      # end
      if cidx
        if cidx <= OBJECT_DIRECT_MAX
          str = [ BC_OBJECT_DIRECT + cidx ].pack('C')
        else
          str = [ BC_OBJECT ].pack('C') << write_int(cidx)
        end
        fmask[cidx].each do |f|
          str << write(val[f], refs, crefs, trefs)
        end
      else
        str = [ BC_MAP_UNTYPED ].pack('C')
        val.each do |k, v|
          str << write(k, refs, crefs, trefs)
          str << write(v, refs, crefs, trefs)
        end
        str << [ BC_END ].pack('C')
      end
      str
    end

    def write_null
      [ BC_NULL ].pack('C')
    end

  end
end
