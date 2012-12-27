require 'hessian2/fault'

module Hessian2
  module Parser
    include Constants

    def parse(data)
      a = data.slice!(0)
      case a
      when 'C' # rpc call
        args = []
        method = parse_object(data)
        parse_object(data).times do
          args << parse_object(data)
        end
        method, *args
      when 'F' # fault
        fault = parse_object(data)
        code, message = fault['code'], fault['message']
        raise Fault.new, code == 'RuntimeError' ? message : "#{code} - #{message}"
      when 'H' # hessian version
        data.slice!(0, 2)
        parse(data)
      when 'R' # rpc result
        parse_object(data)
      else
        raise Fault.new, "'#{a}' not implemented"
      end
    end

    def parse_object(data, vrefs = [], crefs = [])
      c = data.slice!(0).unpack('C')[0]
      case c
      when 0x00..0x1f
        # utf-8 string length 0-32
        data.slice!(0, data.unpack("U#{c - BC_STRING_DIRECT}").pack('U*').bytesize)
      when 0x20..0x2f
        # binary data length 0-16
        data.slice!(0, c - BC_BINARY_DIRECT)
      when 0x30..0x33
        # utf-8 string length 0-1023
        len = ((c - BC_STRING_SHORT) << 8) + data.slice!(0).unpack('C')[0]
        data.slice!(0, data.unpack("U#{len}").pack('U*').bytesize)
      when 0x34..0x37
        # binary data length 0-1023
        len = ((c - BC_BINARY_SHORT) << 8) + data.slice!(0).unpack('C')[0]
        data.slice!(0, len)
      when 0x38..0x3f
        # three-octet compact long (-x40000 to x3ffff)
        b1, b0 = data.slice!(0, 2).unpack('cc')
        ((c - BC_LONG_SHORT_ZERO) << 16) + (b1 << 8) + b2
      when 0x41
        # 8-bit binary data non-final chunk ('A')
        chunks = []
        chunks << cut_binary(data)
        while(data.slice!(0) == 'A')
          chunks << cut_binary(data)
        end
        data.slice!(0) #=> 'B'
        chunks << cut_binary(data)
        chunks.join
      when 0x42
        # 8-bit binary data final chunk ('B')
        cut_binary(data)
      when 0x43
        # object type definition ('C')
        parse_object(data) #=> class name
        attrs = []
        parse_object(data).times do
          attrs << parse_object(data, vrefs, crefs)
        end
        crefs << attrs
        parse_object(data, vrefs, crefs)
      when 0x44
        # 64-bit IEEE encoded double ('D')
        data.slice!(0, 8).unpack('G')[0]
      when 0x46
        # boolean false ('F')
        false
      when 0x48
        # untyped map ('H')
        val = {}
        while data[0] != 'Z'
          val[parse_object(data)] = parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x49
        # 32-bit signed integer ('I')
        data.slice!(0, 4).unpack('l>')[0]
      when 0x4a
        # 64-bit UTC millisecond date
        val = data.slice!(0, 8).unpack('Q>')[0]
        Time.at(val / 1000, val % 1000 * 1000)
      when 0x4b
        # 32-bit UTC minute date
        val = data.slice!(0, 4).unpack('l>')[0]
        Time.at(val * 10)
      when 0x4c
        # 64-bit signed long integer ('L')
        data.slice!(0, 8).unpack('q>')[0]
      when 0x4d
        # map with type ('M')
        parse_object(data) #=> type
        val = {}
        while data[0] != 'Z'
          val[parse_object(data)] = parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x4e
        # null ('N')
        nil
      when 0x4f
        # object instance ('O')
        val = {}
        attrs = crefs[parse_object(data)]
        attrs.each do |a|
          val[a] = parse_object(data, vrefs, crefs)
        end
        val
      when 0x51
        # reference to map/list/object - integer ('Q')
        vrefs[parse_object(data)]
      when 0x52
        # utf-8 string non-final chunk ('R')
        chunks = []
        chunks << cut_string(data)
        while(data.slice!(0) == 'R')
          chunks << cut_string(data)
        end
        data.slice!(0) #=> 'S'
        chunks << cut_string(data)
        chunks.join
      when 0x53
        # utf-8 string final chunk ('S')
        cut_string(data)
      when 0x54
        # boolean true ('T')
        true
      when 0x55
        # variable-length list/vector ('U')
        parse_object(data) #=> type

        val = []
        while data[0] != 'Z'
          val << parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x56
        # fixed-length list/vector ('V')
        parse_object(data) #=> type
        val = []
        parse_object(data, vrefs, crefs).times do
          val << parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        val
      when 0x57
        # variable-length untyped list/vector ('W')
        val = []
        while data[0] != 'Z'
          val << parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        data.slice!(0) #=> 'Z'
        val
      when 0x58
        # fixed-length untyped list/vector ('X')
        val = []
        parse_object(data).times do
          val << parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        val
      when 0x59
        # long encoded as 32-bit int ('Y')
        data.slice!(0, 4).unpack('l>')[0]
      when 0x5b
        # double 0.0
        0
      when 0x5c
        # double 1.0
        1
      when 0x5d
        # double represented as byte (-128.0 to 127.0)
        data.slice!(0).unpack('c')[0]
      when 0x5e
        # double represented as short (-32768.0 to 327676.0)
        b1, b0 = data.slice!(0, 2).unpack('cc')
        (b1 << 8) + b2
      when 0x5f
        # double represented as float
        data.slice!(0, 4).unpack('g')[0]
      when 0x60..0x6f
        # object with direct type
        val = {}
        attrs = crefs[c - BC_OBJECT_DIRECT]
        attrs.each do |a|
          val[a] = parse_object(data, vrefs, crefs)
        end
        val
      when 0x70..0x77
        # fixed list with direct length
        parse_object(data) #=> type
        val = []
        (c - BC_LIST_DIRECT).times do
          val << parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        val
      when 0x78..0x7f
        # fixed untyped list with direct length
        val = []
        (c - BC_LIST_DIRECT_UNTYPED).times do
          val << parse_object(data, vrefs, crefs)
        end
        vrefs << val # store a value reference
        val
      when 0x80..0xbf
        # one-octet compact int (-x10 to x3f, x90 is 0)
        c - BC_INT_ZERO
      when 0xc0..0xcf
        # two-octet compact int (-x800 to x7ff)
        ((c - BC_INT_BYTE_ZERO) << 8) + data.slice!(0).unpack('c')
      when 0xd0..0xd7
        # three-octet compact int (-x40000 to x3ffff)
        b1, b0 = data.slice!(0, 2).unpack('cc')
        ((c - BC_INT_SHORT_ZERO) << 16) + (b1 << 8) + b0
      when 0xd8..0xef
        # one-octet compact long (-x8 to xf, xe0 is 0)
        c - BC_LONG_ZERO
      when 0xf0..0xff
        # two-octet compact long (-x800 to x7ff, xf8 is 0)
        ((c - BC_LONG_BYTE_ZERO) << 8) + data.slice!(0).unpack('c')
      else
        raise Fault.new, "'#{c}' not implemented"
      end
    end

    private
    def cut_string(data)
      len = data.slice!(0, 2).unpack('n')[0]
      data.slice!(0, data.unpack("U#{len}").pack('U*').bytesize)
    end

    def cut_binary(data)
      data.slice!(0, data.slice!(0, 2).unpack('n')[0])
    end

  end 
end
