require 'hessian2/constants'
require 'bigdecimal'
require 'active_record'

module Hessian2
  module Writer
    include Constants

    def call(method, args)
      refs, crefs, trefs = {}, {}, {}
      out = [ 'H', '2', '0', 'C' ].pack('ahha')
      out << write_string(method)
      out << write_int(args.size)
      args.each{|arg| out << write(arg, refs, crefs, trefs) }

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
      when StructWrapper # object to values-array
        write_struct_wrapper(val, refs, crefs, trefs)
      when ClassWrapper # class definition for statically typed languages
        write_class_wrapper(val, refs, crefs, trefs)
      when TypeWrapper
        write_type_wrapper(val, refs, crefs, trefs)
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
        write_float(val)
      when Fixnum
        write_int(val)
      when Array, ActiveRecord::Relation
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


    def write_class_wrapper(val, refs, crefs, trefs)
      return write_nil unless val.values

      idx = refs[val.object_id]
      return write_ref(idx) if idx

      refs[val.object_id] = refs.size

      if val.is_multi?
        type = '[' << val.klass
        if trefs.include?(type)
          tstr = write_int(trefs[type])
        else
          trefs[type] = trefs.size # store a type
          tstr = write_string(type)
        end
        return [ BC_LIST_DIRECT ].pack('C') << tstr if val.values.size == 0
      end

      cref = crefs[val.klass]
      if cref
        cidx = cref.first
        fields = cref.last
        str = ''
      else
        fstr = val.fields.map{|f| write_string(f) }.join
        
        str = [ BC_OBJECT_DEF ].pack('C') << write_string(val.klass) << write_int(val.fields.size) << fstr
        cidx = crefs.size
        crefs[val.klass] = [cidx, val.fields] # store a class definition
      end

      if cidx <= OBJECT_DIRECT_MAX
        cstr = [ BC_OBJECT_DIRECT + cidx ].pack('C')
      else
        cstr = [ BC_OBJECT ].pack('C') << write_int(cidx)
      end

      if val.is_multi?
        len = val.values.size
        if len <= LIST_DIRECT_MAX # [x70-77] type value*
          str << [ BC_LIST_DIRECT + len ].pack('C') << tstr
        else  # 'V' type int value*
          str << [ BC_LIST_FIXED ].pack('C') << tstr << write_int(len)
        end

        val.values.each do |ele|
          if ele
            ele_idx = refs[ele.object_id]
            if ele_idx
              str << (cstr + write_ref(ele_idx))
            else
              refs[ele.object_id] = refs.size
              str << (cstr + ele.map{|v| write(v, refs, crefs, trefs)}.join)
            end
          else
            str << write_nil
          end
        end
      else
        str << (cstr + val.values.map{|v| write(v, refs, crefs, trefs)}.join)
      end

      str
    end


    def write_float(val)
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


    def write_object(object, refs = {}, crefs = {}, trefs = {})
      return write_nil unless object

      idx = refs[object.object_id]
      return write_ref(idx) if idx

      refs[object.object_id] = refs.size

      klass = object.class.to_s
      cref = crefs[klass]
      if cref
        cidx = cref.first
        fields = cref.last
        str = ''
      else
        fields = get_fields(object)
        fstr = fields.map{|f| write_string(f) }.join
        cidx = crefs.size
        crefs[klass] = [cidx, fields]

        str = [ BC_OBJECT_DEF ].pack('C') << write_string(klass) << write_int(fields.size) << fstr
      end
      
      if cidx <= OBJECT_DIRECT_MAX
        cstr = [ BC_OBJECT_DIRECT + cidx ].pack('C')
      else
        cstr = [ BC_OBJECT ].pack('C') << write_int(cidx)
      end

      str << write_values(object, cstr, fields, refs, crefs, trefs)

      str
    end


    def write_ref(val)
      [ BC_REF ].pack('C') << write_int(val)
    end


    def write_struct_wrapper(val, refs, crefs, trefs)
      return write_nil unless val.values

      idx = refs[val.object_id]
      return write_ref(idx) if idx

      refs[val.object_id] = refs.size

      write_array(val.values, refs, crefs, trefs)
    end


    def write_string(str)
      chunks, i, len = '', 0, str.size
      while len > 0x8000
        chunks << [ BC_STRING_CHUNK, 0x8000 ].pack('Cn') << print_string(str[i...(i += 0x8000)])
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
        arr.each do |ele|
          idx = refs[ele.object_id]
          if idx
            str << write_ref(idx)
          else
            refs[ele.object_id] = refs.size
            str << write_type_wrapped_object(ele, tstr, refs, crefs, trefs)
          end
        end
      end
      
      str
    end


    def write_type_wrapped_object(object, tstr, refs = {}, crefs = {}, trefs = {})
      return write_nil unless object

      str = [ BC_MAP ].pack('C') << tstr

      if object.is_a?(Hash)
        object.each do |k, v|
          str << write(k, refs, crefs, trefs)
          str << write(v, refs, crefs, trefs)
        end
      elsif object.instance_variable_get(:@attributes).is_a?(Hash)
        object.attributes.each do |k, v|
          str << write(k, refs, crefs, trefs)
          str << write(v, refs, crefs, trefs)
        end
      elsif object.is_a?(ClassWrapper)
        object.fields.each_with_index do |f, i|
          str << write(f, refs, crefs, trefs)
          str << write(object.values[i], refs, crefs, trefs)
        end
      elsif object.is_a?(TypeWrapper)
        object.object.each do |k, v|
          str << write(k, refs, crefs, trefs)
          str << write(v, refs, crefs, trefs)
        end
      else
        object.instance_variables.each do |var| 
          str << write(var[1..-1], refs, crefs, trefs)
          str << write(object.instance_variable_get(var), refs, crefs, trefs)
        end
      end

      str << [ BC_END ].pack('C')
    end


    def write_type_wrapper(val, refs, crefs, trefs)
      return write_nil unless val.object

      idx = refs[val.object_id]
      return write_ref(idx) if idx

      refs[val.object_id] = refs.size

      type = val.is_multi? ? ('[' << val.hessian_type) : val.hessian_type
      if trefs.include?(type)
        tstr = write_int(trefs[type])
      else
        trefs[type] = trefs.size
        tstr = write_string(type)
      end

      if val.is_multi?
        write_type_wrapped_array(val.object, tstr, val.hessian_type, refs, crefs, trefs)
      else
        case val.hessian_type
        when 'L'
          write_long(Integer(val.object))
        when 'I'
          write_int(Integer(val.object))
        when 'B'
          write_binary(val.object)
        else
          write_type_wrapped_object(val.object, tstr, refs, crefs, trefs)
        end
      end
    end


    private

    def get_fields(object)
      fields = if object.is_a?(Hash)
        object.keys.map{|k| k.to_sym }
      elsif object.instance_variable_get(:@attributes).is_a?(Hash)
        object.attributes.keys.map{|k| k.to_sym }
      else
        object.instance_variables.map{|k| k[1..-1].to_sym }
      end

      raise "fields should not be empty: #{object.inspect}" if fields.empty?

      fields
    end


    def write_values(object, cstr, fields, refs, crefs, trefs)
      return write_nil unless object
      
      vstr = if object.is_a?(Hash)
        fields.map{|f| write(object[f] || object[f.to_s], refs, crefs, trefs) }.join
      elsif object.instance_variable_get(:@attributes).is_a?(Hash)
        fields.map{|f| write(object.attributes[f.to_s], refs, crefs, trefs) }.join
      else
        fields.map{|f| write(object.instance_variable_get(f.to_s.prepend('@')), refs, crefs, trefs) }.join
      end

      cstr + vstr
    end

  end
end
