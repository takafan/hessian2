require 'hessian2/constants'
require 'bigdecimal'

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
      [ 'F' ].pack('a') << write_hash(val)
    end

    def write(val, refs = {}, crefs = {}, trefs = {})
      case val
      when StructWrapper # ([)object to ([)values-array
        obj = val.object
        return write_nil if obj.nil?

        idx = refs[val.object_id]
        return write_ref(idx) if idx

        refs[val.object_id] = refs.size

        klass = val.klass
        
        if klass.is_a? Array
          fields = klass.first.members
          arr = []

          obj.each do |o|
            ovals = []
            if o.is_a? Hash
              fields.each do |f|
                ovals << (o[f] || o[f.to_s])
              end
            elsif o.instance_variable_get(:@attributes).is_a? Hash
              attrs = o.attributes
              fields.each do |f|
                ovals << attrs[f.to_s]
              end
            else
              fields.each do |f|
                ovals << o.instance_variable_get(f.to_s.prepend('@'))
              end
            end
            arr << ovals
          end

          write_array(arr, refs, crefs, trefs)
        else
          objvals = []
          if obj.is_a? Hash
            klass.members.each do |f|
              objvals << (obj[f] || obj[f.to_s])
            end
          elsif obj.instance_variable_get(:@attributes).is_a? Hash
            attrs = obj.attributes
            klass.members.each do |f|
              objvals << attrs[f.to_s]
            end
          else
            klass.members.each do |f|
              objvals << obj.instance_variable_get(f.to_s.prepend('@'))
            end
          end
        
          write_array(objvals, refs, crefs, trefs)
        end
      when ClassWrapper # class definition for statically typed languages
        obj = val.object
        return write_nil if obj.nil?

        idx = refs[val.object_id]
        return write_ref(idx) if idx

        refs[val.object_id] = refs.size

        if val.hessian_class[0] == '['
          type = val.hessian_class
          if trefs.include?(type)
            tstr = write_int(trefs[type])
          else
            trefs[type] = trefs.size # store a type
            tstr = write_string(type)
          end
          return [ BC_LIST_DIRECT ].pack('C') << tstr if obj.size == 0
        end

        klass = val.hessian_class.delete('[]')
        cref = crefs[klass]
        if cref
          cidx = cref.first
          fields = cref.last
          str = ''
        else
          fstr = ''
          if obj.is_a? Array
            sample = obj.first
            if sample.is_a? Hash
              fields = sample.keys
              fields.each do |f|
                fstr << write_string(f.to_s)
              end
            else
              fields = sample.instance_variables
              fields.each do |f|
                fstr << write_string(f.to_s[1..-1]) # skip '@'
              end
            end
          elsif obj.is_a? Hash
            fields = obj.keys
            fields.each do |f|
              fstr << write_string(f.to_s)
            end
          else
            fields = obj.instance_variables
            fields.each do |f|
              fstr << write_string(f.to_s[1..-1])
            end
          end

          str = [ BC_OBJECT_DEF ].pack('C') << write_string(klass) << write_int(fields.size) << fstr
          cidx = crefs.size
          crefs[klass] = [cidx, fields] # store a class definition
        end

        if cidx <= OBJECT_DIRECT_MAX
          cstr = [ BC_OBJECT_DIRECT + cidx ].pack('C')
        else
          cstr = [ BC_OBJECT ].pack('C') << write_int(cidx)
        end

        if obj.is_a? Array
          str << write_class_wrapped_array(obj, tstr, cstr, fields, refs, crefs, trefs)
        elsif obj.is_a? Hash
          str << write_class_wrapped_hash(obj, cstr, fields, refs, crefs, trefs)
        else
          str << write_class_wrapped_object(obj, cstr, fields, refs, crefs, trefs)
        end

        str
      when TypeWrapper
        obj = val.object
        return write_nil if obj.nil?

        idx = refs[val.object_id]
        return write_ref(idx) if idx

        refs[val.object_id] = refs.size

        type = val.hessian_type
        if trefs.include?(type)
          tstr = write_int(trefs[type])
        else
          trefs[type] = trefs.size
          tstr = write_string(type)
        end

        if type[0] == '['
          write_type_wrapped_array(obj, tstr, type, refs, crefs, trefs)
        else
          case type
          when 'L'
            write_long(Integer(obj))
          when 'I'
            write_int(Integer(obj))
          when 'B'
            write_binary(obj)
          else
            if obj.is_a? Hash
              write_type_wrapped_hash(obj, tstr, refs, crefs, trefs)
            else
              write(obj, refs, crefs, trefs)
            end
          end
        end
      when TrueClass
        [ BC_TRUE ].pack('C')
      when FalseClass
        [ BC_FALSE ].pack('C')
      when Time
        if val.usec == 0 && val.sec == 0 # date in minutes
          [ BC_DATE_MINUTE, val.to_i / 60 ].pack('CL>')
        else
          [ BC_DATE, val.to_i * 1000 + val.usec / 1000 ].pack('CQ>') # date
        end
      when Float, BigDecimal
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
            return [ BC_DOUBLE_BYTE, ival ].pack('Cc') if ival >= -0x80 && ival <= 0x7f # double octet
            return [ BC_DOUBLE_SHORT, (ival >> 8), ival ].pack('Ccc') if ival >= -0x8000 && ival <= 0x7fff # double short
          end

          mval = val * 1000
          if mval.finite?
            mills = mval.to_i
            if mills >= -0x80_000_000 && mills <= 0x7f_fff_fff && 0.001 * mills == val
              return [ BC_DOUBLE_MILL, mills ].pack('Cl>') # double mill
            end
          end

          [ BC_DOUBLE, val ].pack('CG') # double
        end
      when Fixnum
        write_int(val)
      when Array
        write_array(val, refs, crefs, trefs)
      when Bignum
        if val >= -0x80_000_000 && val <= 0x7f_fff_fff # four octet longs
          [ BC_LONG_INT, val ].pack('Cl>')
        else # long
          [ BC_LONG, val ].pack('Cq>')
        end
      when Hash
        write_hash(val, refs, crefs, trefs)
      when NilClass
        write_nil
      when String
        write_string(val)
      when Symbol
        write_string(val.to_s)
      else
        write_object(val, refs, crefs, trefs)
      end
    end

    def print_string(str)
      return str.b if String.method_defined?(:b)

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

    def write_array(arr, refs = {}, crefs = {}, trefs = {})
      idx = refs[arr.object_id]
      return write_ref(idx) if idx

      refs[arr.object_id] = refs.size
      len = arr.size
      if len <= LIST_DIRECT_MAX # [x78-7f] value*
        str = [ BC_LIST_DIRECT_UNTYPED + len ].pack('C')
      else  # x58 int value*
        str = [ BC_LIST_FIXED_UNTYPED ].pack('C') << write_int(len)
      end

      arr.each do |ele|
        str << write(ele, refs, crefs, trefs)
      end

      str
    end

    def write_binary(str)
      chunks, i, len = [], 0, str.size
      while len > 0x8000
        chunks << [ BC_BINARY_CHUNK, 0x8000 ].pack('Cn') << str[i...(i += 0x8000)]
        len -= 0x8000
      end

      final = str[i..-1]
      if len <= BINARY_DIRECT_MAX
        chunks << [ BC_BINARY_DIRECT + len ].pack('C') << final
      elsif len <= BINARY_SHORT_MAX
        chunks << [ BC_BINARY_SHORT + (len >> 8), len ].pack('CC') << final
      else
        chunks << [ BC_BINARY, len ].pack('Cn') << final
      end

      chunks.join
    end

    def write_class_wrapped_array(arr, tstr, cstr, fields, refs = {}, crefs = {}, trefs = {})
      len = arr.size
      if len <= LIST_DIRECT_MAX # [x70-77] type value*
        str = [ BC_LIST_DIRECT + len ].pack('C') << tstr
      else  # 'V' type int value*
        str = [ BC_LIST_FIXED ].pack('C') << tstr << write_int(len)
      end

      if arr.first.is_a? Hash
        arr.each do |ele|
          idx = refs[ele.object_id]
          if idx
            str << write_ref(idx)
          else
            refs[ele.object_id] = refs.size
            str << cstr
            fields.each do |f|
              str << write(ele[f], refs, crefs, trefs)
            end
          end
        end
      else
        arr.each do |ele|
          idx = refs[ele.object_id]
          if idx
            str << write_ref(idx)
          else
            refs[ele.object_id] = refs.size
            str << cstr
            fields.each do |f|
              str << write(ele.instance_variable_get(f), refs, crefs, trefs)
            end
          end
        end
      end

      str
    end

    def write_class_wrapped_hash(hash, cstr, fields, refs = {}, crefs = {}, trefs = {})
      str = cstr
      fields.each do |f|
        str << write(hash[f], refs, crefs, trefs)
      end

      str
    end

    def write_class_wrapped_object(obj, cstr, fields, refs = {}, crefs = {}, trefs = {})
      str = cstr
      fields.each do |f|
        str << write(obj.instance_variable_get(f), refs, crefs, trefs)
      end

      str
    end

    def write_hash(hash, refs = {}, crefs = {}, trefs = {})
      idx = refs[hash.object_id]
      return write_ref(idx) if idx

      refs[hash.object_id] = refs.size
      str = [ BC_MAP_UNTYPED ].pack('C')
      hash.each do |k, v|
        str << write(k, refs, crefs, trefs)
        str << write(v, refs, crefs, trefs)
      end

      str << [ BC_END ].pack('C')
    end

    def write_int(val)
      if val >= INT_DIRECT_MIN && val <= INT_DIRECT_MAX # single octet integers
        [ BC_INT_ZERO + val ].pack('c')
      elsif val >= INT_BYTE_MIN && val <= INT_BYTE_MAX # two octet integers
        [ BC_INT_BYTE_ZERO + (val >> 8), val ].pack('cc')
      elsif val >= INT_SHORT_MIN && val <= INT_SHORT_MAX # three octet integers
        [ BC_INT_SHORT_ZERO + (val >> 16), (val >> 8), val].pack('ccc')
      elsif val >= -0x80_000_000 && val <= 0x7f_fff_fff # integer
        [ BC_INT, val ].pack('Cl>')
      else
        [ BC_LONG, val ].pack('Cq>')
      end
    end

    def write_long(val)
      if val >= LONG_DIRECT_MIN && val <= LONG_DIRECT_MAX # single octet longs
        [ BC_LONG_ZERO + val ].pack('c')
      elsif val >= LONG_BYTE_MIN && val <= LONG_BYTE_MAX # two octet longs
        [ BC_LONG_BYTE_ZERO + (val >> 8), val ].pack('cc')
      elsif val >= LONG_SHORT_MIN && val <= LONG_SHORT_MAX # three octet longs
        [ BC_LONG_SHORT_ZERO + (val >> 16), (val >> 8), val ].pack('ccc')
      elsif val >= -0x80_000_000 && val <= 0x7f_fff_fff # four octet longs
        [ BC_LONG_INT, val ].pack('Cl>')
      else
        [ BC_LONG, val ].pack('Cq>')
      end
    end

    def write_nil
      [ BC_NULL ].pack('C')
    end

    def write_object(obj, refs = {}, crefs = {}, trefs = {})
      idx = refs[obj.object_id]
      return write_ref(idx) if idx

      attrs = obj.instance_variable_get(:@attributes)

      refs[obj.object_id] = refs.size
      klass = obj.class.to_s
      cref = crefs[klass]
      if cref
        cidx = cref.first
        fields = cref.last
        str = ''
      else
        fields = attrs.is_a?(Hash) ? attrs.keys : obj.instance_variables.map{|sym| sym.to_s[1..-1]}
        str = [ BC_OBJECT_DEF ].pack('C') << write_string(klass) << write_int(fields.size)
        fields.each do |f|
          str << write_string(f)
        end

        cidx = crefs.size
        crefs[klass] = [cidx, fields]
      end
      
      if cidx <= OBJECT_DIRECT_MAX
        str << [ BC_OBJECT_DIRECT + cidx ].pack('C')
      else
        str << [ BC_OBJECT ].pack('C') << write_int(cidx)
      end

      if attrs.is_a? Hash
        fields.each do |f|
          str << write(attrs[f], refs, crefs, trefs)
        end
      else
        fields.each do |f|
          str << write(obj.instance_variable_get(f.prepend('@')), refs, crefs, trefs)
        end
      end

      str
    end

    def write_ref(val)
      [ BC_REF ].pack('C') << write_int(val)
    end

    def write_string(str)
      chunks, i, len = '', 0, str.size
      while len > 0x8000
        chunks << [ BC_STRING_CHUNK, 0x8000 ].pack('Cn') << print_string(str[i, i += 0x8000])
        len -= 0x8000
      end

      final = str[i..-1]
      chunks << if len <= STRING_DIRECT_MAX
        [ BC_STRING_DIRECT + len ].pack('C')
      elsif len <= STRING_SHORT_MAX
        [ BC_STRING_SHORT + (len >> 8), len ].pack('CC')
      else
        [ BC_STRING, len ].pack('Cn')
      end

      chunks << print_string(final)
    end

    def write_type_wrapped_array(arr, tstr, eletype, refs = {}, crefs = {}, trefs = {})
      len = arr.size
      return [ BC_LIST_DIRECT ].pack('C') << tstr if len == 0

      if len <= LIST_DIRECT_MAX # [x70-77] type value*
        str = [ BC_LIST_DIRECT + len ].pack('C') << tstr
      else  # 'V' type int value*
        str = [ BC_LIST_FIXED ].pack('C') << tstr << write_int(len)
      end

      case eletype
      when 'L'
        arr.each do |ele|
          str << write_long(Integer(ele))
        end
      when 'I'
        arr.each do |ele|
          str << write_int(Integer(ele))
        end
      when 'B'
        arr.each do |ele|
          str << write_binary(ele)
        end
      else
        if arr.first.is_a? Hash
          arr.each do |ele|
            idx = refs[ele.object_id]
            if idx
              str << write_ref(idx)
            else
              refs[ele.object_id] = refs.size
              str << write_type_wrapped_hash(ele, tstr, refs, crefs, trefs)
            end
          end
        else
          arr.each do |ele|
            idx = refs[ele.object_id]
            if idx
              str << write_ref(idx)
            else
              refs[ele.object_id] = refs.size
              str << write(ele, refs, crefs, trefs)
            end
          end
        end
      end
      
      str
    end

    def write_type_wrapped_hash(hash, tstr, refs = {}, crefs = {}, trefs = {})
      str = [ BC_MAP ].pack('C') << tstr
      hash.each do |k, v|
        str << write(k, refs, crefs, trefs)
        str << write(v, refs, crefs, trefs)
      end

      str << [ BC_END ].pack('C')
    end

  end
end
