require 'hessian2/constants'
require 'hessian2/fault'

module Hessian2
  module Parser
    include Constants

    def self.parse_rpc(data)
      bytes = data.bytes
      bc = bytes.next
      if bc == 0x48 # skip hessian version
        2.times{ bytes.next }
        bc = bytes.next
      end
      case bc
      when 0x43 # rpc call ('C')
        method = self.parse_string(bytes)
        args = [].tap do |arr|
          self.parse_int(bytes).times{ arr << self.parse_bytes(bytes) }
        end
        [ method, *args ]
      when 0x46 # fault ('F')
        fault = self.parse_bytes(bytes)
        code, message = fault['code'], fault['message']
        puts code
        puts message
        raise Fault.new, code == 'RuntimeError' ? message : "#{code} - #{message}"
      when 0x52 # rpc result ('R')
        self.parse_bytes(bytes)
      else
        raise Fault.new, "'#{bc}' not implemented"
      end
    end

    def self.parse(data)
      self.parse_bytes(data.bytes, refs = [], cdefs = [])
    end

    private

    def self.parse_bytes(bytes, refs = [], cdefs = [])
      bc = bytes.next
      case bc
      when 0x00..0x1f # utf-8 string length 0-31
        self.read_string_direct(bytes, bc)
      when 0x20..0x2f # binary data length 0-15
        self.read_binary_direct(bytes, bc)
      when 0x30..0x33 # utf-8 string length 0-1023
        self.read_string_short(bytes, bc)
      when 0x34..0x37 # binary data length 0-1023
        self.read_binary_short(bytes, bc)
      when 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
        self.read_long_short_zero(bytes, bc)
      when 0x41 # 8-bit binary data non-final chunk ('A')
        self.read_binary_chunk(bytes)
      when 0x42 # 8-bit binary data final chunk ('B')
        self.read_binary(bytes)
      when 0x43 # object type definition ('C')
        self.parse_string(bytes) # skip class name
        attrs = []
        cdefs << attrs
        parse_int(bytes).times{ attrs << self.parse_string(bytes) } # store a class reference
        self.parse_bytes(bytes, refs, cdefs)
      when 0x44 # 64-bit IEEE encoded double ('D')
        self.read_double(bytes)
      when 0x46 # boolean false ('F')
        false
      when 0x48 # untyped map ('H')
        val = {}
        refs << val # store a value reference first
        while bytes.peek != BC_END
          val[self.parse_bytes(bytes, refs, cdefs)] = self.parse_bytes(bytes, refs, cdefs)
        end
        bytes.next
        val
      when 0x49 # 32-bit signed integer ('I')
        self.read_int(bytes)
      when 0x4a # 64-bit UTC millisecond date
        self.read_date(bytes)
      when 0x4b # 32-bit UTC minute date
        self.read_date_minute(bytes)
      when 0x4c # 64-bit signed long integer ('L')
        self.read_long(bytes)
      when 0x4d # map with type ('M')
        self.parse_string(bytes) # skip type
        val = {}
        refs << val # store a value reference first
        while bytes.peek != BC_END
          val[self.parse_bytes(bytes, refs, cdefs)] = self.parse_bytes(bytes, refs, cdefs)
        end
        bytes.next
        val
      when 0x4e # null ('N')
        nil
      when 0x4f # object instance ('O')
        val = {}
        refs << val
        cdefs[self.parse_int(bytes)].each do |f| 
          val[f] = self.parse_bytes(bytes, refs, cdefs)
        end
        val
      when 0x51 # reference to map/list/object - integer ('Q')
        refs[self.parse_int(bytes)]
      when 0x52 # utf-8 string non-final chunk ('R')
        self.read_string_chunk(bytes)
      when 0x53 # utf-8 string final chunk ('S')
        self.read_string(bytes)
      when 0x54 # boolean true ('T')
        true
      when 0x55 # variable-length list/vector ('U')
        self.parse_string(bytes) # skip type
        val = []
        refs << val # store a value reference first
        while bytes.next != BC_END
          val << self.parse_bytes(bytes, refs, cdefs)
        end
        bytes.next
        val
      when 0x56 # fixed-length list/vector ('V')
        self.parse_string(bytes) # skip type
        refs << val # store a value reference
        self.parse_int(bytes).times do |i| 
          val[i] = self.parse_bytes(bytes, refs, cdefs)
        end
        val
      when 0x57 # variable-length untyped list/vector ('W')
        val = []
        refs << val # store a value reference first
        while bytes.peek != BC_END
          val << self.parse_bytes(bytes, refs, cdefs)
        end
        bytes.next
        val
      when 0x58 # fixed-length untyped list/vector ('X')
        val = []
        refs << val # store a value reference first
        self.parse_int(bytes).times do |i| 
          val << self.parse_bytes(bytes, refs, cdefs)
        end
        val
      when 0x59 # long encoded as 32-bit int ('Y')
        self.read_int(bytes)
      when 0x5b # double 0.0
        0
      when 0x5c # double 1.0
        1
      when 0x5d # double represented as byte (-128.0 to 127.0)
        self.read_double_direct(bytes)
      when 0x5e # double represented as short (-32768.0 to 32767.0)
        self.read_double_short(bytes)
      when 0x5f # double represented as float
        self.read_double_mill(bytes)
      when 0x60..0x6f # object with direct type
        val = {}
        refs << val # store a value reference first
        cdefs[bc - BC_OBJECT_DIRECT].each do |f| 
          val[f] = self.parse_bytes(bytes, refs, cdefs)
        end
        val
      when 0x70..0x77 # fixed list with direct length
        self.parse_string(bytes) # skip type
        val = []
        refs << val # store a value reference first
        (bc - BC_LIST_DIRECT).times do
          val << self.parse_bytes(bytes, refs, cdefs)
        end
        val
      when 0x78..0x7f # fixed untyped list with direct length
        val = []
        refs << val # store a value reference first
        (bc - BC_LIST_DIRECT_UNTYPED).times do
          val << self.parse_bytes(bytes, refs, cdefs)
        end
        val
      when 0x80..0xbf # one-octet compact int (-x10 to x2f, x90 is 0)
        self.read_int_zero(bc)
      when 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
        self.read_int_byte_zero(bytes, bc)
      when 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
        self.read_int_short_zero(bytes, bc)
      when 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
        self.read_long_zero(bc)
      when 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
        self.read_long_byte_zero(bytes, bc)
      else
        raise Fault.new, "Invalid type: '#{bc}'"
      end
    end

    def self.parse_utf8_char(bytes)
      bc = bytes.next
      if bc < 0x80 # 0xxxxxxx
        bc
      elsif bc & 0xe0 == 0xc0 # 110xxxxx 10xxxxxx
        ((bc & 0x1f) << 6) + (bytes.next & 0x3f)
      elsif bc & 0xf0 == 0xe0 # 1110xxxx 10xxxxxx 10xxxxxx
        ((bc & 0x0f) << 12) + ((bytes.next & 0x3f) << 6) + (bytes.next & 0x3f)
      else
        raise Fault.new, "bad utf-8 encoding at '#{bc}'"
      end
    end

    def self.parse_binary(bytes)
      bc = bytes.next
      case bc
      when 0x20..0x2f
        self.read_binary_direct(bytes, bc)
      when 0x34..0x37
        self.read_binary_short(bytes, bc)
      when 0x41
        self.read_binary_chunk(bytes)
      when 0x42
        self.read_binary(bytes)
      else
        raise Fault.new, "'#{bc}' is not a binary"
      end
    end

    def self.parse_int(bytes)
      bc = bytes.next
      case bc
      when 0x49
        self.read_int(bytes)
      when 0x80..0xbf
        self.read_int_zero(bc)
      when 0xc0..0xcf
        self.read_int_byte_zero(bytes, bc)
      when 0xd0..0xd7
        self.read_int_short_zero(bytes, bc)
      else
        raise Fault.new, "'#{bc}' is not a int"
      end
    end

    def self.parse_string(bytes)
      bc = bytes.next
      case bc
      when 0x00..0x1f
        self.read_string_direct(bytes, bc)
      when 0x30..0x33
        self.read_string_short(bytes, bc)
      when 0x52
        self.read_string_chunk(bytes)
      when 0x53
        self.read_string(bytes)
      else
        raise Fault.new, "'#{bc}' is not a string"
      end
    end

    def self.read_binary_direct(bytes, bc)
      self.read_binary_string(bytes, bc - BC_BINARY_DIRECT)
    end

    def self.read_binary_short(bytes, bc)
      self.read_binary_string(bytes, ((bc - BC_BINARY_SHORT) << 8) + bytes.next)
    end

    def self.read_binary_chunk(bytes)
      chunks = []
      chunks << self.read_binary(bytes)
      while(bytes.peek == BC_BINARY_CHUNK)
        bytes.next # skip 'A'
        chunks << self.read_binary(bytes)
      end
      chunks << self.parse_binary(bytes)
      chunks.join
    end

    def self.read_binary(bytes)
      self.read_binary_string(bytes, (bytes.next << 8) + bytes.next)
    end

    def self.read_binary_string(bytes, len)
      [].tap do |arr|
        len.times{ arr << bytes.next } 
      end.pack('C*')
    end

    def self.read_date(bytes)
      val = self.read_long(bytes)
      Time.at(val / 1000, val % 1000 * 1000)
    end

    def self.read_date_minute(bytes)
      val = (bytes.next << 24) + (bytes.next << 16) + (bytes.next << 8) + bytes.next
      Time.at(val * 60)
    end

    def self.read_double(bytes)
      b64, b56, b48, b40, b32, b24, b16, b8 = bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next
      bits = (b64 << 56) + (b56 << 48) + (b48 << 40) + (b40 << 32) + (b32 << 24) + (b24 << 16) + (b16 << 8) + b8
      return Float::INFINITY if bits == 0x7_ff0_000_000_000_000
      return -Float::INFINITY if bits == 0xf_ff0_000_000_000_000
      return Float::NAN if (0x7_ff0_000_000_000_001..0x7_fff_fff_fff_fff_fff).include?(bits) or (0xf_ff0_000_000_000_001..0xf_fff_fff_fff_fff_fff).include?(bits)
      s = b64 < 0x80 ? 1 : -1
      e = (bits >> 52) & 0x7ff
      m = (e == 0) ? (bits & 0xf_fff_fff_fff_fff) << 1 : (bits & 0xf_fff_fff_fff_fff) | 0x10_000_000_000_000
      s * m * 2**(e - 1075)
    end

    def self.read_double_direct(bytes)
      bc = bytes.next
      bc < 0x80 ? bc : -(0xff - bc + 1)
    end

    def self.read_double_short(bytes)
      b16, b8 = bytes.next, bytes.next
      if b16 < 0x80
        (b16 << 8) + b8
      else
        -(((0xff - b16) << 8) + 0xff - b8 + 1)
      end
    end

    def self.read_double_mill(bytes)
      0.001 * self.read_int(bytes)
    end

    def self.read_int(bytes)
      b32, b24, b16, b8 = bytes.next, bytes.next, bytes.next, bytes.next
      if b32 < 0x80
        (b32 << 24) + (b24 << 16) + (b16 << 8) + b8
      else
        -(((0xff - b32) << 24) + ((0xff - b24) << 16) + ((0xff - b16) << 8) + 0xff - b8 + 1)
      end
    end

    def self.read_int_zero(bc)
      bc - BC_INT_ZERO
    end

    def self.read_int_byte_zero(bytes, bc)
      ((bc - BC_INT_BYTE_ZERO) << 8) + bytes.next
    end

    def self.read_int_short_zero(bytes, bc)
      ((bc - BC_INT_SHORT_ZERO) << 16) + (bytes.next << 8) + bytes.next
    end

    def self.read_long(bytes)
      b64, b56, b48, b40, b32, b24, b16, b8 = bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next, bytes.next
      if b64 < 0x80
        (b64 << 56) + (b56 << 48) + (b48 << 40) + (b40 << 32) \
          + (b32 << 24) + (b24 << 16) + (b16 << 8) + b8
      else
        -(((0xff - b64) << 56) + ((0xff - b56) << 48) + ((0xff - b48) << 40) + ((0xff - b40) << 32) \
          + ((0xff - b32) << 24) + ((0xff - b24) << 16) + ((0xff - b16) << 8) + 0xff - b8 + 1)
      end
    end

    def self.read_long_zero(bc)
      bc - BC_LONG_ZERO
    end

    def self.read_long_byte_zero(bytes, bc)
      ((bc - BC_LONG_BYTE_ZERO) << 8) + bytes.next
    end

    def self.read_long_short_zero(bytes, bc)
      ((bc - BC_LONG_SHORT_ZERO) << 16) + (bytes.next << 8) + bytes.next
    end

    def self.read_string_direct(bytes, bc)
      self.read_utf8_string(bytes, bc - BC_STRING_DIRECT)
    end

    def self.read_string_short(bytes, bc)
      self.read_utf8_string(bytes, ((bc - BC_STRING_SHORT) << 8) + bytes.next)
    end

    def self.read_string_chunk(bytes)
      chunks = []
      chunks << self.read_string(bytes)
      while(bytes.peek == BC_STRING_CHUNK)
        bytes.next # skip 'R'
        chunks << self.read_string(bytes)
      end
      chunks << self.parse_string(bytes)
      chunks.join
    end

    def self.read_string(bytes)
      self.read_utf8_string(bytes, (bytes.next << 8) + bytes.next)
    end

    def self.read_utf8_string(bytes, len)
      [].tap do |chars|
        len.times{ chars << self.parse_utf8_char(bytes) }
      end.pack('U*')
    end

  end 
end
