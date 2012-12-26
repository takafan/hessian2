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

    def parse_object(data, vrefs = [], crefs = [], trefs = [])
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
        length = ((c - BC_STRING_SHORT) << 8) + data.slice!(0).unpack('C')[0]
        data.slice!(0, data.unpack("U#{length}").pack('U*').bytesize)
      when 0x34..0x37
        # binary data length 0-1023
        length = ((c - BC_BINARY_SHORT) << 8) + data.slice!(0).unpack('C')[0]
        data.slice!(0, length)
      when 0x38..0x3f
        # three-octet compact long (-x40000 to x3ffff)
        b1, b0 = data.slice!(0, 2).unpack('CC')
        ((c - BC_LONG_SHORT_ZERO) << 16) + (b1 << 8) + b2
      when 0x41
        # 8-bit binary data non-final chunk ('A')
        chunks = []
        chunks << data.slice!(0, data.slice!(0, 2).unpack('n')[0])
        while(data.slice!(0) == 'A')
          chunks << data.slice!(0, data.slice!(0, 2).unpack('n')[0])
        end
        data.slice!(0) #=> 'B'
        chunks << data.slice!(0, data.slice!(0, 2).unpack('n')[0])
        chunks.join
      when 0x42          # 8-bit binary data final chunk ('B')
        data.slice!(0, data.slice!(0, 2).unpack('n')[0])
      when 0x43          # object type definition ('C')
        klass = parse_object(data)
        attrc = parse_object(data)
        attrc.times do
          parse_object(data)
        end
        crefs[klass]
      when 0x44          # 64-bit IEEE encoded double ('D')
        data.slice!(0, 8).unpack('G')[0]
      when 0x46          # boolean false ('F')
        false
      when 0x48          # untyped map ('H')
        
      when 0x49          # 32-bit signed integer ('I')
      when 0x4a          # 64-bit UTC millisecond date
      when 0x4b          # 32-bit UTC minute date
      when 0x4c          # 64-bit signed long integer ('L')
      when 0x4d          # map with type ('M')
      when 0x4e          # null ('N')
      when 0x4f          # object instance ('O')
      when 0x51          # reference to map/list/object - integer ('Q')
      when 0x52          # utf-8 string non-final chunk ('R')
      when 0x53          # utf-8 string final chunk ('S')
      when 0x54          # boolean true ('T')
      when 0x55          # variable-length list/vector ('U')
      when 0x56          # fixed-length list/vector ('V')
      when 0x57          # variable-length untyped list/vector ('W')
      when 0x58          # fixed-length untyped list/vector ('X')
      when 0x59          # long encoded as 32-bit int ('Y')
      when 0x5a          # list/map terminator ('Z')
      when 0x5b          # double 0.0
      when 0x5c          # double 1.0
      when 0x5d          # double represented as byte (-128.0 to 127.0)
      when 0x5e          # double represented as short (-32768.0 to 327676.0)
      when 0x5f          # double represented as float
      when 0x60..0x6f    # object with direct type
      when 0x70..0x77    # fixed list with direct length
      when 0x78..0x7f    # fixed untyped list with direct length
      when 0x80..0xbf    # one-octet compact int (-x10 to x3f, x90 is 0)
      when 0xc0..0xcf    # two-octet compact int (-x800 to x7ff)
      when 0xd0..0xd7    # three-octet compact int (-x40000 to x3ffff)
      when 0xd8..0xef    # one-octet compact long (-x8 to xf, xe0 is 0)
      when 0xf0..0xff    # two-octet compact long (-x800 to x7ff, xf8 is 0)
      
      else
        raise Fault.new, "'#{c}' not implemented"
      end
    end

  end 
end


