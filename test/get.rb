# -*- encoding: utf-8 -*-

lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require ::File.expand_path('../monkey',  __FILE__)

c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')

# 0x00..0x1f # utf-8 string length 0-31
c1.get_string_0
c1.get_string_x1f
c1.get_string_x1fu

# 0x20..0x2f # binary data length 0-15
c1.get_bin_0
c1.get_bin_xf

# 0x30..0x33 # utf-8 string length 0-1023
c1.get_string_x20
c1.get_string_x20u
c1.get_string_x3ff
c1.get_string_x3ffu

# 0x34..0x37 # binary data length 0-1023
c1.get_bin_x10
c1.get_bin_x3ff

# 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
c1.get_long_mx801
c1.get_long_x800
c1.get_long_mx40000
c1.get_long_x3ffff

# 0x41 # 8-bit binary data non-final chunk ('A')
c1.get_lighthouse

# 0x42 # 8-bit binary data final chunk ('B')
c1.get_bin_x400
c1.get_bin_x8000

# 0x43 # object type definition ('C')
# 0x60..0x6f # object with direct type
c1.get_monkey_monkey(monkey1, monkey2)

# 0x44 # 64-bit IEEE encoded double ('D')
c1.get_double_min
c1.get_double_max

# 0x46 # boolean false ('F')
c1.get_false

# 0x48 # untyped map ('H')
c1.get_map_h

# 0x49 # 32-bit signed integer ('I')
c1.get_int_mx40001
c1.get_int_x40000
c1.get_int_mx40_000_000
c1.get_int_x3f_fff_fff


# 0x4a # 64-bit UTC millisecond date
c1.get_date_20130112145959

# 0x4b # 32-bit UTC minute date
c1.get_date_201301121459

# 0x4c # 64-bit signed long integer ('L')
c1.get_long_mx8_000_000_000_000_000
c1.get_long_x7_fff_fff_fff_fff_fff

# 0x4d # map with type ('M')
c1.get_monkey_monkey

# 0x4e # null ('N')
c1.get_null

# 0x4f # object instance ('O')
begin c1.get_monkeys; rescue Hessian2::Fault => e; puts "#{e.message}"; end

# 0x51 # reference to map/list/object - integer ('Q')
c1.get_map_list_monkey_map_list_monkey

# 0x52 # utf-8 string non-final chunk ('R')
c1.get_string_x8001
c1.get_string_x8001u

# 0x53 # utf-8 string final chunk ('S')
c1.get_string_x400
c1.get_string_x400u
c1.get_string_x8000
c1.get_string_x8000u

# 0x54 # boolean true ('T')
c1.get_true

# 0x55 # variable-length list/vector ('U')
# hessian2 write fixed-length list only

# 0x56 # fixed-length list/vector ('V')
c1.get_list

# 0x57 # variable-length untyped list/vector ('W')
# hessian2 write fixed-length list only

# 0x58 # fixed-length untyped list/vector ('X')
c1.get_list

# 0x59 # long encoded as 32-bit int ('Y')
c1.get_long_mx40001
c1.get_long_x40000
c1.get_long_mx80_000_000
c1.get_long_x7f_fff_fff

# 0x5b # double 0.0
c1.get_double_0

# 0x5c # double 1.0
c1.get_double_1

# 0x5d # double represented as byte (-128.0 to 127.0)
c1.get_double_m128
c1.get_double_127

# 0x5e # double represented as short (-32768.0 to 32767.0)
c1.get_double_m129
c1.get_double_128
c1.get_double_m32768
c1.get_double_32767

# 0x5f # double represented as float
# hessian2 write double-precision only

# 0x70..0x77 # fixed list with direct length
c1.get_list_size0
c1.get_list_size7

# 0x78..0x7f # fixed untyped list with direct length
c1.get_list_size0
c1.get_list_size7

# 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
c1.get_int_mx10
c1.get_int_x3f

# 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
c1.get_int_mx11
c1.get_int_x40
c1.get_int_mx800
c1.get_int_x7ff

# 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
c1.get_int_mx801
c1.get_int_x800
c1.get_int_mx40000
c1.get_int_x3ffff

# 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
c1.get_long_mx8
c1.get_long_xf

# 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
c1.get_long_mx9
c1.get_long_x10
c1.get_long_mx800
c1.get_long_x7ff
