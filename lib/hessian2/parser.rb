require 'hessian2/constants'
require 'hessian2/fault'

module Hessian2
  module Parser
    include Constants

    def self.parse(data)
      @data = data
      @i = 0
      @refs, @cdefs = [], []

      c = @data[@i]
      c = @data[@i += 3] if c == 'H' # hessian version
      case c
      when 'C' # rpc call
        method = self.parse_string
        args = [].tap do |arr|
          self.parse_int.times{ arr << self.parse_string }
        end
        [ method, *args ]
      when 'F' # fault
        fault = self.parse_data
        code, message = fault['code'], fault['message']
        raise Fault.new, code == 'RuntimeError' ? message : "#{code} - #{message}"
      when 'R' # rpc result
        self.parse_data
      else
        raise Fault.new, "'#{c}' not implemented"
      end
    end

    def self.parse_data
      c = @data[@i += 1].unpack('C')[0]
      case c
      when 0x00..0x1f # utf-8 string length 0-31
        self.read_string_direct(c)
      when 0x20..0x2f # binary data length 0-15
        self.read_binary_direct(c)
      when 0x30..0x33 # utf-8 string length 0-1023
        self.read_string_short(c)
      when 0x34..0x37 # binary data length 0-1023
        self.read_binary_short(c)
      when 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
        self.read_long_short_zero(c)
      when 0x41 # 8-bit binary data non-final chunk ('A')
        self.read_binary_chunk
      when 0x42 # 8-bit binary data final chunk ('B')
        self.read_binary
      when 0x43 # object type definition ('C')
        self.parse_string # skip class name
        @cdefs << [].tap do |arr|
          self.parse_int.times{ arr << self.parse_string }
        end # store a class reference
        self.parse_data
      when 0x44 # 64-bit IEEE encoded double ('D')
        self.read_double
      when 0x46 # boolean false ('F')
        false
      when 0x48 # untyped map ('H')
        val = {}
        while @data[@i + 1] != 'Z'
          val[self.parse_data] = self.parse_data
        end
        @refs << val # store a value reference
        @i += 1 # skip 'Z'
        val
      when 0x49 # 32-bit signed integer ('I')
        self.read_int
      when 0x4a # 64-bit UTC millisecond date
        self.read_date
      when 0x4b # 32-bit UTC minute date
        self.read_date_minute
      when 0x4c # 64-bit signed long integer ('L')
        self.read_long
      when 0x4d # map with type ('M')
        self.parse_string # skip type
        val = {}
        while @data[@i + 1] != 'Z'
          val[self.parse_data] = self.parse_data
        end
        @refs << val # store a value reference
        @i += 1 # skip 'Z'
        val
      when 0x4e # null ('N')
        nil
      when 0x4f # object instance ('O')
        obj = {}.tap do |o|
          @cdefs[self.parse_int].each{ |a| o[a] = self.parse_data }
        end
        @refs << obj
        obj
      when 0x51 # reference to map/list/object - integer ('Q')
        @refs[self.parse_int]
      when 0x52 # utf-8 string non-final chunk ('R')
        self.read_string_chunk
      when 0x53 # utf-8 string final chunk ('S')
        self.read_string
      when 0x54 # boolean true ('T')
        true
      when 0x55 # variable-length list/vector ('U')
        self.parse_string #=> type
        val = []
        while @data[@i + 1] != 'Z'
          val << self.parse_data
        end
        @refs << val # store a value reference
        @i += 1 # skip 'Z'
        val
      when 0x56 # fixed-length list/vector ('V')
        self.parse_string # skip type
        val = []
        self.parse_int.times do
          val << self.parse_data
        end
        @refs << val # store a value reference
        val
      when 0x57 # variable-length untyped list/vector ('W')
        val = []
        while @data[@i + 1] != 'Z'
          val << self.parse_data
        end
        @refs << val # store a value reference
        @i += 1 # skip 'Z'
        val
      when 0x58 # fixed-length untyped list/vector ('X')
        val = []
        self.parse_int.times do
          val << self.parse_data
        end
        @refs << val # store a value reference
        val
      when 0x59 # long encoded as 32-bit int ('Y')
        self.read_long_int
      when 0x5b # double 0.0
        0
      when 0x5c # double 1.0
        1
      when 0x5d # double represented as byte (-128.0 to 127.0)
        self.read_double_byte
      when 0x5e # double represented as short (-32768.0 to 32767.0)
        self.read_double_short
      when 0x5f # double represented as float
        self.read_double_mill
      when 0x60..0x6f # object with direct type
        obj = {}.tap do |o|
          @cdefs[c - BC_OBJECT_DIRECT].each{ |a| o[a] = self.parse_data }
        end
        @refs << obj
        obj
      when 0x70..0x77 # fixed list with direct length
        self.parse_string # skip type
        val = []
        (c - BC_LIST_DIRECT).times do
          val << self.parse_data
        end
        @refs << val # store a value reference
        val
      when 0x78..0x7f # fixed untyped list with direct length
        val = []
        (c - BC_LIST_DIRECT_UNTYPED).times do
          val << self.parse_data
        end
        @refs << val # store a value reference
        val
      when 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
        self.read_int_zero(c)
      when 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
        self.read_int_byte_zero(c)
      when 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
        self.read_int_short_zero(c)
      when 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
        self.read_long_zero(c)
      when 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
        self.read_long_byte_zero(c)
      else
        raise Fault.new, "Invalid type: '#{c}'"
      end
    end

    private
    def self.parse_char
      c = @data[@i += 1].unpack('C')[0]
      if c < 0x80
        c
      elsif c & 0xe0 == 0xc0
        c1 = @data[@i += 1].unpack('C')[0]
        ((c & 0x1f) << 6) + (c1 & 0x3f)
      elsif c & 0xf0 == 0xe0
        c1, c2 = @data[@i...(@i += 2)].unpack('C2')
        ((c & 0x0f) << 12) + ((c1 & 0x3f) << 6) + (c2 & 0x3f)
      else
        raise Fault.new, "bad utf-8 encoding at '#{c}'"
      end
    end

    def self.parse_int
      c = @data[@i += 1].unpack('C')[0]
      case c
      when 0x49
        self.read_int
      when 0x80..0xbf
        self.read_int_zero(c)
      when 0xc0..0xcf
        self.read_int_byte_zero(c)
      when 0xd0..0xd7
        self.read_int_short_zero(c)
      else
        raise Fault.new, "'#{c}' is not a int"
      end
    end

    def self.parse_string
      c = @data[@i += 1].unpack('C')[0]
      case c
      when 0x00..0x1f
        self.read_string_direct(c)
      when 0x30..0x33
        self.read_string_short(c)
      when 0x52
        self.read_string_chunk
      when 0x53
        self.read_string
      else
        raise Fault.new, "'#{c}' is not a string"
      end
    end

    def self.read_binary_direct(c)
      @data[@i...(@i + c - BC_BINARY_DIRECT)]
    end

    def self.read_binary_short(c)
      len = ((c - BC_BINARY_SHORT) << 8) + @data[@i += 1].unpack('C')[0]
      @data[@i...(@i += len)]
    end

    def self.read_binary_large
      chunks = []
      chunks << self.read_binary
      while(@data[@i += 1] == 'A')
        chunks << self.read_binary
      end
      @i += 1 # skip 'B'
      chunks << self.read_binary
      chunks.join
    end

    def self.read_binary
      len = @data[@i...(@i += 2)].unpack('n')[0]
      @data[@i...(@i += len)]
    end

    def self.read_date
      val = @data[@i...(@i += 8)].unpack('Q>')[0]
      Time.at(val / 1000, val % 1000 * 1000)
    end

    def self.read_date_minute
      val = @data[@i...(@i += 4)].unpack('L>')[0]
      Time.at(val * 60)
    end

    def self.read_double
      @data[@i...(@i += 8)].unpack('G')[0]
    end

    def self.read_double_byte
      @data[@i += 1].unpack('c')[0]
    end

    def self.read_double_short
      b1, b0 = @data[@i...(@i += 2)].unpack('cc')
      (b1 << 8) + b2
    end

    def self.read_double_mill
      @data[@i...(@i += 4)].unpack('g')[0]
    end

    def self.read_int
      @data[@i...(@i += 4)].unpack('l>')[0]
    end

    def self.read_int_zero(c)
      c - BC_INT_ZERO
    end

    def self.read_int_byte_zero(c)
      ((c - BC_INT_BYTE_ZERO) << 8) + @data[@i += 1].unpack('c')[0]
    end

    def self.read_int_short_zero(c)
      b1, b0 = @data[@i...(@i += 2)].unpack('cc')
      ((c - BC_INT_SHORT_ZERO) << 16) + (b1 << 8) + b0
    end

    def self.read_long
      @data[@i...(@i += 8)].unpack('q>')[0]
    end

    def self.read_long_zero(c)
      c - BC_LONG_ZERO
    end

    def self.read_long_byte_zero(c)
      ((c - BC_LONG_BYTE_ZERO) << 8) + @data[@i += 1].unpack('c')[0]
    end

    def self.read_long_short_zero(c)
      b1, b0 = @data[@i...(@i += 2)].unpack('cc')
      ((c - BC_LONG_SHORT_ZERO) << 16) + (b1 << 8) + b2
    end

    def self.read_long_int
      @data[@i...(@i += 4)].unpack('l>')[0]
    end

    def self.read_string_direct(c)
      [].tap do |chars|
        (c - BC_STRING_DIRECT).times{ chars << self.parse_char }
      end.pack('U*')
    end

    def self.read_string_short(c)
      [].tap do |chars|
        (((c - BC_STRING_SHORT) << 8) + @data[@i += 1].unpack('C')[0]).times{ chars << self.parse_char }
      end.pack('U*')
    end

    def self.read_string_chunk
      chunks = []
      chunks << self.read_string
      while(@data[@i += 1] == 'R')
        chunks << self.read_string
      end
      @i += 1 # skip 'S'
      chunks << self.read_string
      chunks.join
    end

    def self.read_string
      [].tap do |chars|
        @data[@i...(@i += 2)].unpack('n')[0].times{ chars << self.parse_char }
      end.pack('U*')
    end

  end 
end
