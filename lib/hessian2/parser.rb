require 'hessian2/constants'
require 'hessian2/fault'

module Hessian2
  module Parser
    include Constants

    def parse_rpc(data)
      bytes = data.each_byte
      bc = bytes.next
      if bc == 0x48 # skip hessian version
        2.times{ bytes.next }
        bc = bytes.next
      end

      case bc
      when 0x43 # rpc call ('C')
        method = parse_string(bytes)
        refs, cdefs = [], []
        args = [].tap do |arr|
          parse_int(bytes).times{ arr << parse_bytes(bytes, nil, {}, refs, cdefs) }
        end
        [ method, *args ]
      when 0x46 # fault ('F')
        fault = parse_bytes(bytes)
        code, message = fault['code'], fault['message']
        raise Fault.new, code == 'RuntimeError' ? message : "#{code} - #{message}"
      when 0x52 # rpc result ('R')
        parse_bytes(bytes)
      else
        raise data
      end
    end

    def parse(data, klass = nil, options = {})
      parse_bytes(data.each_byte, klass, options)
    end

    def parse_bytes(bytes, klass = nil, options = {}, refs = [], cdefs = [])
      bc = bytes.next
      case bc
      when 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
           0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 
           0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
           0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
        # 0x00 - 0x1f utf-8 string length 0-31
        read_string_direct(bytes, bc)
      when 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
           0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f
        # 0x20 - 0x2f binary data length 0-15
        read_binary_direct(bytes, bc)
      when 0x30, 0x31, 0x32, 0x33
        # 0x30 - 0x33 utf-8 string length 0-1023
        read_string_short(bytes, bc)
      when 0x34, 0x35, 0x36, 0x37
        # 0x34 - 0x37 binary data length 0-1023
        read_binary_short(bytes, bc)
      when 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f
        # 0x38 - 0x3f three-octet compact long (-x40000 to x3ffff)
        read_long_short_zero(bytes, bc)
      when 0x41 # 8-bit binary data non-final chunk ('A')
        read_binary_chunk(bytes)
      when 0x42 # 8-bit binary data final chunk ('B')
        read_binary(bytes)
      when 0x43 # object type definition ('C')
        name = parse_string(bytes)
        fields = []

        parse_int(bytes).times do
          fields << parse_string(bytes)
        end
        cdefs << Struct.new(*fields.map{|f| f.to_sym})

        parse_bytes(bytes, klass, options, refs, cdefs)
      when 0x44 # 64-bit IEEE encoded double ('D')
        read_double(bytes)
      when 0x46 # boolean false ('F')
        false
      when 0x48 # untyped map ('H')
        val = {}
        refs << val # store a value reference first
        while bytes.peek != BC_END
          val[parse_bytes(bytes, klass, options, refs, cdefs)] = parse_bytes(bytes, klass, options, refs, cdefs)
        end

        bytes.next
        options[:symbolize_keys] ? val.inject({}){|memo, (k, v)| memo[k.to_sym] = v; memo} : val
      when 0x49 # 32-bit signed integer ('I')
        read_int(bytes)
      when 0x4a # 64-bit UTC millisecond date
        read_date(bytes)
      when 0x4b # 32-bit UTC minute date
        read_date_minute(bytes)
      when 0x4c # 64-bit signed long integer ('L')
        read_long(bytes)
      when 0x4d # map with type ('M')
        parse_type(bytes)
        val = {}
        refs << val
        while bytes.peek != BC_END
          val[parse_bytes(bytes, klass, options, refs, cdefs)] = parse_bytes(bytes, klass, options, refs, cdefs)
        end

        bytes.next
        options[:symbolize_keys] ? val.inject({}){|memo, (k, v)| memo[k.to_sym] = v; memo} : val
      when 0x4e # null ('N')
        nil
      when 0x4f # object instance ('O')
        cdef = cdefs[parse_int(bytes)]
        val = cdef.new
        refs << val # store a value reference first
        val.members.each do |sym|
          val[sym] = parse_bytes(bytes, klass, options, refs, cdefs)
        end

        val
      when 0x51 # reference to map/list/object - integer ('Q')
        refs[parse_int(bytes)]
      when 0x52 # utf-8 string non-final chunk ('R')
        read_string_chunk(bytes)
      when 0x53 # utf-8 string final chunk ('S')
        read_string(bytes)
      when 0x54 # boolean true ('T')
        true
      when 0x55 # variable-length list/vector ('U')
        parse_type(bytes)

        is_struct, klass = parse_klass(klass)

        if is_struct
          arr = []
          while bytes.peek != BC_END
            arr << parse_bytes(bytes, nil, options, refs, cdefs)
          end

          val = klass.new(*arr)
          refs << val
        else
          val = []
          refs << val # store a value reference first
          while bytes.peek != BC_END
            val << parse_bytes(bytes, klass, options, refs, cdefs)
          end
        end

        bytes.next
        val
      when 0x56 # fixed-length list/vector ('V')
        parse_type(bytes)

        is_struct, klass = parse_klass(klass)

        if is_struct
          arr = []
          parse_int(bytes).times do
            arr << parse_bytes(bytes, nil, options, refs, cdefs)
          end

          val = klass.new(*arr)
          refs << val
        else
          val = []
          refs << val # store a value reference
          parse_int(bytes).times do
            val << parse_bytes(bytes, klass, options, refs, cdefs)
          end
        end

        val
      when 0x57 # variable-length untyped list/vector ('W')
        is_struct, klass = parse_klass(klass)

        if is_struct
          arr = []
          while bytes.peek != BC_END
            arr << parse_bytes(bytes, nil, options, refs, cdefs)
          end

          val = klass.new(*arr)
          refs << val
        else
          val = []
          refs << val # store a value reference first
          while bytes.peek != BC_END
            val << parse_bytes(bytes, klass, options, refs, cdefs)
          end
        end

        bytes.next
        val
      when 0x58 # fixed-length untyped list/vector ('X')
        is_struct, klass = parse_klass(klass)

        if is_struct
          arr = []
          parse_int(bytes).times do
            arr << parse_bytes(bytes, nil, options, refs, cdefs)
          end

          val = klass.new(*arr)
          refs << val
        else
          val = []
          refs << val # store a value reference first
          parse_int(bytes).times do
            val << parse_bytes(bytes, klass, options, refs, cdefs)
          end
        end

        val
      when 0x59 # long encoded as 32-bit int ('Y')
        read_int(bytes)
      when 0x5b # double 0.0
        0
      when 0x5c # double 1.0
        1
      when 0x5d # double represented as byte (-128.0 to 127.0)
        read_double_direct(bytes)
      when 0x5e # double represented as short (-32768.0 to 32767.0)
        read_double_short(bytes)
      when 0x5f # double represented as float
        read_double_mill(bytes)
      when 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
           0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f
        # 0x60 - 0x6f object with direct type
        cdef = cdefs[bc - BC_OBJECT_DIRECT]
        val = cdef.new
        refs << val # store a value reference first
        val.members.each do |sym|
          val[sym] = parse_bytes(bytes, klass, options, refs, cdefs)
        end

        val
      when 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77
        # 0x70 - 0x77 fixed list with direct length
        parse_type(bytes)

        is_struct, klass = parse_klass(klass)

        if is_struct
          arr = []
          (bc - BC_LIST_DIRECT).times do
            arr << parse_bytes(bytes, nil, options, refs, cdefs)
          end

          val = klass.new(*arr)
          refs << val
        else
          val = []
          refs << val # store a value reference first
          (bc - BC_LIST_DIRECT).times do
            val << parse_bytes(bytes, klass, options, refs, cdefs)
          end
        end

        val
      when 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f
        # 0x78 - 0x7f fixed untyped list with direct length
        is_struct, klass = parse_klass(klass)

        if is_struct
          arr = []
          (bc - BC_LIST_DIRECT_UNTYPED).times do
            arr << parse_bytes(bytes, nil, options, refs, cdefs)
          end

          val = klass.new(*arr)
          refs << val
        else
          val = []
          refs << val # store a value reference first
          (bc - BC_LIST_DIRECT_UNTYPED).times do
            val << parse_bytes(bytes, klass, options, refs, cdefs)
          end
        end

        val
      when 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
           0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
           0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
           0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
           0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
           0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
           0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
           0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf
        # 0x80 - 0xbf one-octet compact int (-x10 to x2f, x90 is 0)
        read_int_zero(bc)
      when 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
           0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf
        # 0xc0 - 0xcf two-octet compact int (-x800 to x7ff)
        read_int_byte_zero(bytes, bc)
      when 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7
        # 0xd0 - 0xd7 three-octet compact int (-x40000 to x3ffff)
        read_int_short_zero(bytes, bc)
      when 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
           0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7,
           0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef
        # 0xd8 - 0xef one-octet compact long (-x8 to xf, xe0 is 0)
        read_long_zero(bc)
      when 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7,
           0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff
        # 0xf0 - 0xff two-octet compact long (-x800 to x7ff, xf8 is 0)
        read_long_byte_zero(bytes, bc)
      else
        raise sprintf("Invalid type: %#x", bc)
      end
    end

    def parse_utf8_char(bytes)
      bc = bytes.next
      if bc < 0x80 # 0xxxxxxx
        bc
      elsif bc & 0xe0 == 0xc0 # 110xxxxx 10xxxxxx
        (bc & 0x1f) * 64 + (bytes.next & 0x3f)
      elsif bc & 0xf0 == 0xe0 # 1110xxxx 10xxxxxx 10xxxxxx
        (bc & 0x0f) * 4096 + (bytes.next & 0x3f) * 64 + (bytes.next & 0x3f)
      else
        raise sprintf("bad utf-8 encoding at %#x", bc)
      end
    end

    def parse_binary(bytes)
      bc = bytes.next
      case bc
      when 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
           0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f
        read_binary_direct(bytes, bc)
      when 0x34, 0x35, 0x36, 0x37
        read_binary_short(bytes, bc)
      when 0x41
        read_binary_chunk(bytes)
      when 0x42
        read_binary(bytes)
      else
        raise sprintf("%#x is not a binary", bc)
      end
    end

    def parse_int(bytes)
      bc = bytes.next
      case bc
      when 0x49
        read_int(bytes)
      when 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
           0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
           0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
           0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
           0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
           0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
           0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
           0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf
        read_int_zero(bc)
      when 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
           0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf
        read_int_byte_zero(bytes, bc)
      when 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7
        read_int_short_zero(bytes, bc)
      else
        raise sprintf("%#x is not a int", bc)
      end
    end

    def parse_string(bytes)
      bc = bytes.next
      case bc
      when 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
           0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 
           0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
           0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
        read_string_direct(bytes, bc)
      when 0x30, 0x31, 0x32, 0x33
        read_string_short(bytes, bc)
      when 0x52
        read_string_chunk(bytes)
      when 0x53
        read_string(bytes)
      else
        raise sprintf("%#x is not a string", bc)
      end
    end

    def parse_type(bytes)
      bc = bytes.next
      case bc
      when 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
           0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 
           0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
           0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
        read_string_direct(bytes, bc)
      when 0x30, 0x31, 0x32, 0x33
        read_string_short(bytes, bc)
      when 0x49
        read_int(bytes)
      when 0x52
        read_string_chunk(bytes)
      when 0x53
        read_string(bytes)
      when 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
           0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
           0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
           0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
           0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
           0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
           0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
           0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf
        read_int_zero(bc)
      when 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
           0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf
        read_int_byte_zero(bytes, bc)
      when 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7
        read_int_short_zero(bytes, bc)
      else
        raise sprintf("%#x is not a type", bc)
      end
    end

    def parse_klass(klass)
      if klass.nil?
        is_struct = false
      elsif klass.is_a?(Array)
        is_struct = false
        klass = klass.first
      elsif klass.is_a?(String)
        if klass.include?('[')
          is_struct = false
          klass = Kernel.const_get(klass.delete('[]'))
        else
          is_struct = true
          klass = Kernel.const_get(klass)
        end
      else
        is_struct = true
      end

      [ is_struct, klass ]
    end

    private

    def read_binary_direct(bytes, bc)
      read_binary_string(bytes, bc - BC_BINARY_DIRECT)
    end

    def read_binary_short(bytes, bc)
      read_binary_string(bytes, ((bc - BC_BINARY_SHORT) << 8) + bytes.next)
    end

    def read_binary_chunk(bytes)
      chunks = []
      chunks << read_binary(bytes)
      while(bytes.peek == BC_BINARY_CHUNK)
        bytes.next
        chunks << read_binary(bytes)
      end

      chunks << parse_binary(bytes)
      chunks.join
    end

    def read_binary(bytes)
      read_binary_string(bytes, bytes.next * 256 + bytes.next)
    end

    def read_binary_string(bytes, len)
      [].tap do |arr|
        len.times{ arr << bytes.next } 
      end.pack('C*')
    end

    def read_date(bytes)
      val = read_long(bytes)
      Time.at(val / 1000, val % 1000 * 1000)
    end

    def read_date_minute(bytes)
      val = bytes.next * 16777216 + bytes.next * 65536 + bytes.next * 256 + bytes.next
      Time.at(val * 60)
    end

    def read_double(bytes)
      # b64, b56, b48, b40, b32, b24, b16, b8 = bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next
      # bits = b64 * 72057594037927936 + b56 * 281474976710656 + b48 * 1099511627776 + b40 * 4294967296 \
      #   + b32 * 16777216 + b24 * 65536 + b16 * 256 + b8
      # return Float::INFINITY if bits == 0x7_ff0_000_000_000_000
      # return -Float::INFINITY if bits == 0xf_ff0_000_000_000_000
      # return Float::NAN if (bits >= 0x7_ff0_000_000_000_001 && bits <= 0x7_fff_fff_fff_fff_fff) or (bits >= 0xf_ff0_000_000_000_001 && bits <= 0xf_fff_fff_fff_fff_fff)
      # s = b64 < 0x80 ? 1 : -1
      # e = (bits / 4503599627370496) & 0x7ff
      # m = (e == 0) ? (bits & 0xf_fff_fff_fff_fff) << 1 : (bits & 0xf_fff_fff_fff_fff) | 0x10_000_000_000_000
      # (s * m * 2**(e - 1075)).to_f # maybe get a rational, so to_f
      [ bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next ].pack('C*').unpack('G').first # faster than s * m * 2**(e - 1075)
    end

    def read_double_direct(bytes)
      bc = bytes.next
      bc < 0x80 ? bc : -(0xff - bc + 1)
    end

    def read_double_short(bytes)
      b16, b8 = bytes.next, bytes.next
      if b16 < 0x80
        b16 * 256 + b8
      else
        -((0xff - b16) * 256 + 0xff - b8 + 1)
      end
    end

    def read_double_mill(bytes)
      0.001 * read_int(bytes)
    end

    def read_int(bytes)
      b32, b24, b16, b8 = bytes.next, bytes.next, bytes.next, bytes.next
      if b32 < 0x80
        b32 * 16777216 + b24 * 65536 + b16 * 256 + b8
      else
        -((0xff - b32) * 16777216 + (0xff - b24) * 65536 + (0xff - b16) * 256 + 0xff - b8 + 1)
      end
    end

    def read_int_zero(bc)
      bc - BC_INT_ZERO
    end

    def read_int_byte_zero(bytes, bc)
      (bc - BC_INT_BYTE_ZERO) * 256 + bytes.next
    end

    def read_int_short_zero(bytes, bc)
      (bc - BC_INT_SHORT_ZERO) * 65536 + bytes.next * 256 + bytes.next
    end

    def read_long(bytes)
      b64, b56, b48, b40, b32, b24, b16, b8 = bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next
      if b64 < 0x80
        b64 * 72057594037927936 + b56 * 281474976710656 + b48 * 1099511627776 + b40 * 4294967296 \
          + b32 * 16777216 + b24 * 65536 + b16 * 256 + b8
      else
        -((0xff - b64) * 72057594037927936 + (0xff - b56) * 281474976710656 + (0xff - b48) * 1099511627776 + (0xff - b40) * 4294967296 \
          + (0xff - b32) * 16777216 + (0xff - b24) * 65536 + (0xff - b16) * 256 + 0xff - b8 + 1)
      end
    end

    def read_long_zero(bc)
      bc - BC_LONG_ZERO
    end

    def read_long_byte_zero(bytes, bc)
      (bc - BC_LONG_BYTE_ZERO) * 256 + bytes.next
    end

    def read_long_short_zero(bytes, bc)
      (bc - BC_LONG_SHORT_ZERO) * 65536 + bytes.next * 256 + bytes.next
    end

    def read_string_direct(bytes, bc)
      read_utf8_string(bytes, bc - BC_STRING_DIRECT)
    end

    def read_string_short(bytes, bc)
      read_utf8_string(bytes, (bc - BC_STRING_SHORT) * 256 + bytes.next)
    end

    def read_string_chunk(bytes)
      chunks = []
      chunks << read_string(bytes)
      while(bytes.peek == BC_STRING_CHUNK)
        bytes.next
        chunks << read_string(bytes)
      end
      
      chunks << parse_string(bytes)
      chunks.join
    end

    def read_string(bytes)
      read_utf8_string(bytes, bytes.next * 256 + bytes.next)
    end

    def read_utf8_string(bytes, len)
      [].tap do |chars|
        len.times{ chars << parse_utf8_char(bytes) }
      end.pack('U*')
    end

  end
end
