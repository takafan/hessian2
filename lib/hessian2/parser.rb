require 'hessian2/constants'
require 'hessian2/fault'

module Hessian2
  module Parser
    include Constants

    def self.parse(data)
      @data, @i, @refs, @cdefs = data.unpack('C*'), 0, [], []

      bc = @data[@i]
      bc = @data[@i += 3] if bc == 0x48 # hessian version ('H')
      case bc
      when 0x43 # rpc call ('C')
        method = self.parse_string
        args = [].tap do |arr|
          self.parse_int.times{ arr << self.parse_string }
        end
        [ method, *args ]
      when 0x46 # fault ('F')
        fault = self.parse_data
        code, message = fault['code'], fault['message']
        raise Fault.new, code == 'RuntimeError' ? message : "#{code} - #{message}"
      when 0x52 # rpc result ('R')
        self.parse_data
      else
        raise Fault.new, "'#{bc}' not implemented"
      end
    end

    def self.parse_data
      bc = self.read
      case bc
      when 0x00..0x1f # utf-8 string length 0-31
        self.read_string_direct(bc)
      when 0x20..0x2f # binary data length 0-15
        self.read_binary_direct(bc)
      when 0x30..0x33 # utf-8 string length 0-1023
        self.read_string_short(bc)
      when 0x34..0x37 # binary data length 0-1023
        self.read_binary_short(bc)
      when 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
        self.read_long_short_zero(bc)
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
        @refs << val # store a value reference first
        while @data[@i + 1] != BC_END
          val[self.parse_data] = self.parse_data
        end
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
        @refs << val # store a value reference first
        while @data[@i + 1] != BC_END
          val[self.parse_data] = self.parse_data
        end
        @i += 1 # skip 'Z'
        val
      when 0x4e # null ('N')
        nil
      when 0x4f # object instance ('O')
        obj = {}.tap do |o|
          @cdefs[self.parse_int].each{ |f| o[f] = self.parse_data }
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
        @refs << val # store a value reference first
        while @data[@i + 1] != BC_END
          val << self.parse_data
        end
        @i += 1 # skip 'Z'
        val
      when 0x56 # fixed-length list/vector ('V')
        self.parse_string # skip type
        len = self.parse_int
        val = Array.new(len)
        @refs << val # store a value reference
        len.times do |i| 
          val[i] = self.parse_data
        end
        val
      when 0x57 # variable-length untyped list/vector ('W')
        val = []
        @refs << val # store a value reference first
        while @data[@i + 1] != BC_END
          val << self.parse_data
        end
        @i += 1 # skip 'Z'
        val
      when 0x58 # fixed-length untyped list/vector ('X')
        len = self.parse_int
        val = Array.new(len)
        @refs << val # store a value reference first
        len.times do |i| 
          val[i] = self.parse_data 
        end
        val
      when 0x59 # long encoded as 32-bit int ('Y')
        self.read_int
      when 0x5b # double 0.0
        0
      when 0x5c # double 1.0
        1
      when 0x5d # double represented as byte (-128.0 to 127.0)
        self.read_double_direct
      when 0x5e # double represented as short (-32768.0 to 32767.0)
        self.read_double_short
      when 0x5f # double represented as float
        self.read_double_mill
      when 0x60..0x6f # object with direct type
        obj = {}
        @refs << obj # store a value reference first
        @cdefs[bc - BC_OBJECT_DIRECT].each do |f| 
          obj[f] = self.parse_data
        end
        obj
      when 0x70..0x77 # fixed list with direct length
        self.parse_string # skip type
        val = []
        @refs << val # store a value reference first
        (bc - BC_LIST_DIRECT).times do
          val << self.parse_data
        end
        val
      when 0x78..0x7f # fixed untyped list with direct length
        val = []
        @refs << val # store a value reference first
        (bc - BC_LIST_DIRECT_UNTYPED).times do
          val << self.parse_data
        end
        val
      when 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
        self.read_int_zero(bc)
      when 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
        self.read_int_byte_zero(bc)
      when 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
        self.read_int_short_zero(bc)
      when 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
        self.read_long_zero(bc)
      when 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
        self.read_long_byte_zero(bc)
      else
        raise Fault.new, "Invalid type: '#{bc}'"
      end
    end

    private
    def self.parse_utf8_char
      bc = self.read
      if bc < 0x80
        bc
      elsif bc & 0xe0 == 0xc0
        ((bc & 0x1f) << 6) + (self.read & 0x3f)
      elsif bc & 0xf0 == 0xe0
        ((bc & 0x0f) << 12) + ((self.read & 0x3f) << 6) + (self.read & 0x3f)
      else
        raise Fault.new, "bad utf-8 encoding at '#{bc}'"
      end
    end

    def self.parse_binary
      bc = self.read
      case bc
      when 0x20..0x2f
        self.read_binary_direct(bc)
      when 0x34..0x37
        self.read_binary_short(bc)
      when 0x41
        self.read_binary_chunk
      when 0x42
        self.read_binary
      else
        raise Fault.new, "'#{bc}' is not a binary"
      end
    end

    def self.parse_int
      bc = self.read
      case bc
      when 0x49
        self.read_int
      when 0x80..0xbf
        self.read_int_zero(bc)
      when 0xc0..0xcf
        self.read_int_byte_zero(bc)
      when 0xd0..0xd7
        self.read_int_short_zero(bc)
      else
        raise Fault.new, "'#{bc}' is not a int"
      end
    end

    def self.parse_string
      bc = self.read
      case bc
      when 0x00..0x1f
        self.read_string_direct(bc)
      when 0x30..0x33
        self.read_string_short(bc)
      when 0x52
        self.read_string_chunk
      when 0x53
        self.read_string
      else
        raise Fault.new, "'#{bc}' is not a string"
      end
    end

    def self.read
      @data[@i += 1]
    end

    def self.read_binary_direct(bc)
      len = bc - BC_BINARY_DIRECT
      Array.new(len).tap do |chars|
        len.times{|i| chars[i] = self.parse_utf8_char }
      end.pack('U*')
    end

    def self.read_binary_short(bc)
      len = ((bc - BC_BINARY_SHORT) << 8) + self.read
      Array.new(len).tap do |chars|
        len.times{|i| chars[i] = self.parse_utf8_char }
      end.pack('U*')
    end

    def self.read_binary_chunk
      chunks = []
      chunks << self.read_binary
      while(@data[@i + 1] == BC_BINARY_CHUNK)
        self.read # skip 'A'
        chunks << self.read_binary
      end
      chunks << self.parse_binary
      chunks.join
    end

    def self.read_binary
      len = (self.read << 8) + self.read
      Array.new(len).tap do |chars|
        len.times{|i| chars[i] = self.parse_utf8_char }
      end.pack('U*')
    end

    def self.read_date
      puts @data[@i, 8].join(', ')
      # get: 74, 0, 0, 1, 60, 45, 142, 205
      # except: 0, 0, 1, 60, 45, 142, 205, 152
      # val = (self.read << 56) + (self.read << 48) + (self.read << 40) + (self.read << 32) 
      #   + (self.read << 24) + (self.read << 16) + (self.read << 8) + self.read
      # val = (self.read + 0x4e) + (self.read << 56) + (self.read << 48) + (self.read << 40) 
      #   + (self.read << 32) + (self.read << 24) + (self.read << 16) + (self.read << 8)
      puts val
      Time.at(val / 1000, val % 1000 * 1000)
    end

    def self.read_date_minute
      val = (self.read << 24) + (self.read << 16) + (self.read << 8) + self.read
      Time.at(val * 60)
    end

    def self.read_double
      [
        self.read, self.read, self.read, self.read, 
        self.read, self.read, self.read, self.read
      ].pack('C*').unpack('G')[0]
    end

    def self.read_double_direct
      bc = self.read
      if bc < 0x80
        bc
      else
        -(0xff - bc + 1)
      end
    end

    def self.read_double_short
      bc1, bc0 = self.read, self.read
      if bc1 < 0x80
        (bc1 << 8) + bc0
      else
        -(((0xff - bc1) << 8) + 0xff - bc0 + 1)
      end
    end

    def self.read_double_mill
      [
        self.read, self.read, self.read, self.read
      ].pack('C*').unpack('g')[0]
    end

    def self.read_int
      bc3, bc2, bc1, bc0 = self.read, self.read, self.read, self.read
      if bc3 < 0x80
        (bc3 << 24) + (bc2 << 16) + (bc1 << 8) + bc0
      else
        -(((0xff - bc3) << 24) + ((0xff - bc2) << 16) + ((0xff - bc1) << 8) + 0xff - bc0 + 1)
      end
    end

    def self.read_int_zero(bc)
      bc - BC_INT_ZERO
    end

    def self.read_int_byte_zero(bc)
      ((bc - BC_INT_BYTE_ZERO) << 8) + self.read
    end

    def self.read_int_short_zero(bc)
      ((bc - BC_INT_SHORT_ZERO) << 16) + (self.read << 8) + self.read
    end

    def self.read_long
      [
        self.read, self.read, self.read, self.read, 
        self.read, self.read, self.read, self.read
      ].pack('C*').unpack('q>')[0]
    end

    def self.read_long_zero(bc)
      bc - BC_LONG_ZERO
    end

    def self.read_long_byte_zero(bc)
      ((bc - BC_LONG_BYTE_ZERO) << 8) + self.read
    end

    def self.read_long_short_zero(bc)
      ((bc - BC_LONG_SHORT_ZERO) << 16) + (self.read << 8) + self.read
    end

    def self.read_string_direct(bc)
      len = bc - BC_STRING_DIRECT
      Array.new(len).tap do |chars|
        len.times{|i| chars[i] = self.parse_utf8_char }
      end.pack('U*')
    end

    def self.read_string_short(bc)
      len = ((bc - BC_STRING_SHORT) << 8) + self.read
      Array.new(len).tap do |chars|
        len.times{|i| chars[i] = self.parse_utf8_char }
      end.pack('U*')
    end

    def self.read_string_chunk
      chunks = []
      chunks << self.read_string
      while(@data[@i + 1] == BC_STRING_CHUNK)
        self.read # skip 'R'
        chunks << self.read_string
      end
      chunks << self.parse_string
      chunks.join
    end

    def self.read_string
      len = (self.read << 8) + self.read
      Array.new(len).tap do |chars|
        len.times{|i| chars[i] = self.parse_utf8_char }
      end.pack('U*')
    end

  end 
end
