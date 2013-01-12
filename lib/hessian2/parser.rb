require 'hessian2/constants'
require 'hessian2/fault'

module Hessian2
  module Parser
    include Constants

    def parse(data)
      data.slice!(0, 3) if data[0] == 'H'
      a = data.slice!(0)
      case a
      when 'C' # rpc call
        args = []
        method = parse_string(data)
        parse_int(data).times do
          args << parse_string(data)
        end
        [ method, *args ]
      when 'F' # fault
        fault = parse_data(data)
        code, message = fault['code'], fault['message']
        raise Fault.new, code == 'RuntimeError' ? message : "#{code} - #{message}"
      when 'R' # rpc result
        parse_data(data)
      else
        raise Fault.new, "'#{a}' not implemented"
      end
    end

    def parse_data(data, refs = [], crefs = [])
      c = data.slice!(0).unpack('C')[0]
      case c
      when 0x00..0x1f # utf-8 string length 0-31
        cut_direct_string(data, c)
      when 0x20..0x2f # binary data length 0-15
        cut_direct_binary(data, c)
      when 0x30..0x33 # utf-8 string length 0-1023
        cut_short_string(data, c)
      when 0x34..0x37 # binary data length 0-1023
        cut_short_binary(data, c)
      when 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
        cut_short_zero_long(data, c)
      when 0x41 # 8-bit binary data non-final chunk ('A')
        cut_large_binary(data)
      when 0x42 # 8-bit binary data final chunk ('B')
        cut_binary(data)
      when 0x43 # object type definition ('C')
        parse_string(data) #=> class name
        attrs = []
        parse_int(data).times do
          attrs << parse_string(data)
        end
        crefs << attrs
        parse_data(data, refs, crefs)
      when 0x44 # 64-bit IEEE encoded double ('D')
        cut_double(data)
      when 0x46 # boolean false ('F')
        false
      when 0x48 # untyped map ('H')
        val = {}
        while data[0] != 'Z'
          val[parse_key(data)] = parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x49 # 32-bit signed integer ('I')
        cut_int(data)
      when 0x4a # 64-bit UTC millisecond date
        cut_date(data)
      when 0x4b # 32-bit UTC minute date
        cut_minute_date(data)
      when 0x4c # 64-bit signed long integer ('L')
        cut_long(data)
      when 0x4d # map with type ('M')
        parse_string(data) #=> type
        val = {}
        while data[0] != 'Z'
          val[parse_key(data)] = parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x4e # null ('N')
        nil
      when 0x4f # object instance ('O')
        obj = {}.tap do |o|
          crefs[parse_int(data)].each{|a| o[a] = parse_data(data, refs, crefs)}
        end
        refs << obj
        obj
      when 0x51 # reference to map/list/object - integer ('Q')
        refs[parse_int(data)]
      when 0x52 # utf-8 string non-final chunk ('R')
        cut_large_string(data)
      when 0x53 # utf-8 string final chunk ('S')
        cut_string(data)
      when 0x54 # boolean true ('T')
        true
      when 0x55 # variable-length list/vector ('U')
        parse_string(data) #=> type
        val = []
        while data[0] != 'Z'
          val << parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x56 # fixed-length list/vector ('V')
        parse_string(data) #=> type
        val = []
        parse_int(data, refs, crefs).times do
          val << parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        val
      when 0x57 # variable-length untyped list/vector ('W')
        val = []
        while data[0] != 'Z'
          val << parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x58 # fixed-length untyped list/vector ('X')
        val = []
        parse_int(data).times do
          val << parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        val
      when 0x59 # long encoded as 32-bit int ('Y')
        cut_32bit_long(data)
      when 0x5b # double 0.0
        0
      when 0x5c # double 1.0
        1
      when 0x5d # double represented as byte (-128.0 to 127.0)
        cut_byte_double(data)
      when 0x5e # double represented as short (-32768.0 to 32767.0)
        cut_short_double(data)
      when 0x5f # double represented as float
        cut_mill_double(data)
      when 0x60..0x6f # object with direct type
        obj = {}.tap do |o|
          crefs[c - BC_OBJECT_DIRECT].each{|a| o[a] = parse_data(data, refs, crefs)}
        end
        refs << obj
        obj
      when 0x70..0x77 # fixed list with direct length
        parse_string(data) #=> type
        val = []
        (c - BC_LIST_DIRECT).times do
          val << parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        val
      when 0x78..0x7f # fixed untyped list with direct length
        val = []
        (c - BC_LIST_DIRECT_UNTYPED).times do
          val << parse_data(data, refs, crefs)
        end
        refs << val # store a value reference
        val
      when 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
        cut_zero_int(c)
      when 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
        cut_byte_zero_int(data, c)
      when 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
        cut_short_zero_int(data, c)
      when 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
        cut_zero_long(c)
      when 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
        cut_byte_zero_long(data, c)
      else
        raise Fault.new, "Invalid type: '#{c}'"
      end
    end

    private
    def parse_key(data) # string, int, long
      c = data.slice!(0).unpack('C')[0]
      case c
      when 0x00..0x1f # utf-8 string length 0-31
        cut_direct_string(data, c)
      when 0x30..0x33 # utf-8 string length 0-1023
        cut_short_string(data, c)
      when 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
        cut_short_zero_long(data, c)
      when 0x49 # 32-bit signed integer ('I')
        cut_32bit_int(data)
      when 0x4c # 64-bit signed long integer ('L')
        cut_long(data)
      when 0x52 # utf-8 string non-final chunk ('R')
        cut_large_string(data)
      when 0x53 # utf-8 string final chunk ('S')
        cut_string(data)
      when 0x59 # long encoded as 32-bit int ('Y')
        cut_32bit_long(data)
      when 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
        cut_zero_int(c)
      when 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
        cut_byte_zero_int(data, c)
      when 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
        cut_short_zero_int(data, c)
      when 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
        cut_zero_long(c)
      when 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
        cut_byte_zero_long(data, c)
      else
        raise Fault.new, "'#{c}' is not a key"
      end
    end

    def parse_int(data)
      c = data.slice!(0).unpack('C')[0]
      case c
      when 0x49 # 32-bit signed integer ('I')
        cut_int(data)
      when 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
        cut_zero_int(c)
      when 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
        cut_byte_zero_int(data, c)
      when 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
        cut_short_zero_int(data, c)
      else
        raise Fault.new, "'#{c}' is not a int"
      end
    end

    def parse_string(data)
      c = data.slice!(0).unpack('C')[0]
      case c
      when 0x00..0x1f # utf-8 string length 0-31
        cut_direct_string(data, c)
      when 0x30..0x33 # utf-8 string length 0-1023
        cut_short_string(data, c)
      when 0x52 # utf-8 string non-final chunk ('R')
        cut_large_string(data)
      when 0x53 # utf-8 string final chunk ('S')
        cut_string(data)
      else
        raise Fault.new, "'#{c}' is not a string"
      end
    end

    def cut_double(data)
      data.slice!(0, 8).unpack('G')[0]
    end

    def cut_byte_double(data)
      data.slice!(0).unpack('c')[0]
    end

    def cut_short_double(data)
      b1, b0 = data.slice!(0, 2).unpack('cc')
      (b1 << 8) + b2
    end

    def cut_mill_double(data)
      data.slice!(0, 4).unpack('g')[0]
    end

    def cut_date(data)
      val = data.slice!(0, 8).unpack('Q>')[0]
      Time.at(val / 1000, val % 1000 * 1000)
    end

    def cut_minute_date(data)
      val = data.slice!(0, 4).unpack('L>')[0]
      Time.at(val * 60)
    end

    def cut_direct_binary(data, c)
      data.slice!(0, c - BC_BINARY_DIRECT)
    end

    def cut_short_binary(data, c)
      len = ((c - BC_BINARY_SHORT) << 8) + data.slice!(0).unpack('C')[0]
      data.slice!(0, len)
    end

    def cut_large_binary(data)
      chunks = []
      chunks << cut_binary(data)
      while(data.slice!(0) == 'A')
        chunks << cut_binary(data)
      end
      data.slice!(0) #=> 'B'
      chunks << cut_binary(data)
      chunks.join
    end

    def cut_binary(data)
      data.slice!(0, data.slice!(0, 2).unpack('n')[0])
    end

    def cut_zero_long(c)
      c - BC_LONG_ZERO
    end

    def cut_byte_zero_long(data, c)
      ((c - BC_LONG_BYTE_ZERO) << 8) + data.slice!(0).unpack('c')[0]
    end

    def cut_short_zero_long(data, c)
      b1, b0 = data.slice!(0, 2).unpack('cc')
      ((c - BC_LONG_SHORT_ZERO) << 16) + (b1 << 8) + b2
    end

    def cut_32bit_long(data)
      data.slice!(0, 4).unpack('l>')[0]
    end

    def cut_long(data)
      data.slice!(0, 8).unpack('q>')[0]
    end

    def cut_zero_int(c)
      c - BC_INT_ZERO
    end

    def cut_byte_zero_int(data, c)
      ((c - BC_INT_BYTE_ZERO) << 8) + data.slice!(0).unpack('c')[0]
    end

    def cut_short_zero_int(data, c)
      b1, b0 = data.slice!(0, 2).unpack('cc')
      ((c - BC_INT_SHORT_ZERO) << 16) + (b1 << 8) + b0
    end

    def cut_int(data)
      data.slice!(0, 4).unpack('l>')[0]
    end

    def cut_direct_string(data, c)
      data.slice!(0, data.unpack("U#{c - BC_STRING_DIRECT}").pack('U*').bytesize)
    end

    def cut_short_string(data, c)
      len = ((c - BC_STRING_SHORT) << 8) + data.slice!(0).unpack('C')[0]
      data.slice!(0, data.unpack("U#{len}").pack('U*').bytesize)
    end

    def cut_large_string(data)
      chunks = []
      chunks << cut_string(data)
      while(data.slice!(0) == 'R')
        chunks << cut_string(data)
      end
      data.slice!(0) #=> 'S'
      chunks << cut_string(data)
      chunks.join
    end

    def cut_string(data)
      len = data.slice!(0, 2).unpack('n')[0]
      data.slice!(0, data.unpack("U#{len}").pack('U*').bytesize)
    end

  end 
end
