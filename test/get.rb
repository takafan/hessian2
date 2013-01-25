# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require ::File.expand_path('../monkey',  __FILE__)

c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')

def print_assert(method, t)
  puts "#{t ? '.' :  '*' * 10 << 'fail'} #{method}"
end

# 0x00..0x1f # utf-8 string length 0-31
v = c1.get_string_0
print_assert 'get_string_0', v == ''
v = c1.get_string_x1f
print_assert 'get_string_x1f', v[0] == 'j' && v.size == 0x1f
v = c1.get_string_x1fu
print_assert 'get_string_x1fu', v[0] == '金' && v.size == 0x1f

# 0x20..0x2f # binary data length 0-15
v = c1.get_bin_0
print_assert 'get_bin_0', v.size == 0
v = c1.get_bin_xf
print_assert 'get_bin_xf', v.size == 0xf

# 0x30..0x33 # utf-8 string length 0-1023
v = c1.get_string_x20
print_assert 'get_string_x20', v[0] == 'j' && v.size == 0x20
v = c1.get_string_x20u
print_assert 'get_string_x20u', v[0] == '金' && v.size == 0x20
v = c1.get_string_x3ff
print_assert 'get_string_x3ff', v[0] == 'j' && v.size == 0x3ff
v = c1.get_string_x3ffu
print_assert 'get_string_x3ffu', v[0] == '金' && v.size == 0x3ff

# 0x34..0x37 # binary data length 0-1023
v = c1.get_bin_x10
print_assert 'get_bin_x10', v.size == 0x10
v = c1.get_bin_x3ff
print_assert 'get_bin_x3ff', v.size == 0x3ff

# 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
v = c1.get_long_mx801
print_assert 'get_long_mx801', v == -0x801
v = c1.get_long_x800
print_assert 'get_long_x800', v == 0x800
v = c1.get_long_mx40000
print_assert 'get_long_mx40000', v == -0x40000
v = c1.get_long_x3ffff
print_assert 'get_long_x3ffff', v == 0x3ffff

# 0x41 # 8-bit binary data non-final chunk ('A')
v = c1.get_lighthouse
print_assert 'get_lighthouse', v.size == 561276

# 0x42 # 8-bit binary data final chunk ('B')
v = c1.get_bin_x400
print_assert 'get_bin_x400', v.size == 0x400
v = c1.get_bin_x8000
print_assert 'get_bin_x8000', v.size == 0x8000

# 0x43 # object type definition ('C')
# 0x60..0x6f # object with direct type
v = c1.get_monkey
print_assert 'get_monkey', v['name'] == '阿门' && v['age'] == 7

# 0x44 # 64-bit IEEE encoded double ('D')
v = c1.get_double_min
print_assert 'get_double_min', v == 4.9E-324
v = c1.get_double_max
print_assert 'get_double_max', v == 1.7976931348623157E308

# 0x46 # boolean false ('F')
v = c1.get_false
print_assert 'get_false', !v

# 0x48 # untyped map ('H')
v = c1.get_map_h
print_assert 'get_map_h', v['name'] == '阿门' && v['age'] == 7

# 0x49 # 32-bit signed integer ('I')
v = c1.get_int_mx40001
print_assert 'get_int_mx40001', v == -0x40001
v = c1.get_int_x40000
print_assert 'get_int_x40000', v == 0x40000
v = c1.get_int_mx40_000_000
print_assert 'get_int_mx40_000_000', v == -0x40_000_000
v = c1.get_int_x3f_fff_fff
print_assert 'get_int_x3f_fff_fff', v == 0x3f_fff_fff

# 0x4a # 64-bit UTC millisecond date
v = c1.get_date_20130112145959
print_assert 'get_date_20130112145959', v == Time.new(2013, 1, 12, 14, 59, 59)

# 0x4b # 32-bit UTC minute date
v = c1.get_date_201301121459
print_assert 'get_date_201301121459', v == Time.new(2013, 1, 12, 14, 59, 0)

# 0x4c # 64-bit signed long integer ('L')
v = c1.get_long_mx8_000_000_000_000_000
print_assert 'get_long_mx8_000_000_000_000_000', v == -0x8_000_000_000_000_000
v = c1.get_long_x7_fff_fff_fff_fff_fff
print_assert 'get_long_x7_fff_fff_fff_fff_fff', v == 0x7_fff_fff_fff_fff_fff
 
# 0x4d # map with type ('M')
v = c1.get_map
print_assert 'get_map', v['name'] == '阿门' && v['age'] == 7

# 0x4e # null ('N')
v = c1.get_null
print_assert 'get_null', v.nil?

# 0x4f # object instance ('O')
v = c1.get_monkeys
print_assert 'get_monkeys', v[0]['name'] == '阿门' && v[0]['age'] == 7 && v[1]['name'] == '大鸡' && v[1]['age'] == 6

# 0x51 # reference to map/list/object - integer ('Q')
v = c1.get_map_h_map_h
print_assert 'get_map_h_map_h', v[0]['name'] == '阿门' && v[0]['age'] == 7 && v[1]['name'] == '阿门' && v[1]['age'] == 7
v = c1.get_monkey_monkey
print_assert 'get_monkey_monkey', v[0]['name'] == '阿门' && v[0]['age'] == 7 && v[1]['name'] == '阿门' && v[1]['age'] == 7
v = c1.get_direct_untyped_list_list
print_assert 'get_direct_untyped_list_list', v[0] == (1..7).to_a && v[1] == (1..7).to_a
v = c1.get_untyped_list_list
print_assert 'get_untyped_list_list', v[0] == (1..7).to_a * 2 && v[1] == (1..7).to_a * 2
v = c1.get_direct_list_list
print_assert 'get_direct_list_list', v[0] == (1..7).to_a && v[1] == (1..7).to_a
v = c1.get_list_list
print_assert 'get_list_list', v[0] == (1..7).to_a * 2 && v[1] == (1..7).to_a * 2


# 0x52 # utf-8 string non-final chunk ('R')
v = c1.get_string_x8001
print_assert 'get_string_x8001', v[0] == 'j' && v.size == 0x8001
v = c1.get_string_x8001u
print_assert 'get_string_x8001u', v[0] == '金' && v.size == 0x8001

# 0x53 # utf-8 string final chunk ('S')
v = c1.get_string_x400
print_assert 'get_string_x400', v[0] == 'j' && v.size == 0x400
v = c1.get_string_x400u
print_assert 'get_string_x400u', v[0] == '金' && v.size == 0x400
v = c1.get_string_x8000
print_assert 'get_string_x8000', v[0] == 'j' && v.size == 0x8000
v = c1.get_string_x8000u
print_assert 'get_string_x8000u', v[0] == '金' && v.size == 0x8000

# 0x54 # boolean true ('T')
v = c1.get_true
print_assert 'get_true', v

# 0x55 # variable-length list/vector ('U')
# hessian2 write fixed-length list only

# 0x56 # fixed-length list/vector ('V')
v = c1.get_list
print_assert 'get_list', v == (1..7).to_a * 2

# 0x57 # variable-length untyped list/vector ('W')
# hessian2 write fixed-length list only

# 0x58 # fixed-length untyped list/vector ('X')
v = c1.get_untyped_list
print_assert 'get_untyped_list', v == (1..7).to_a * 2

# 0x59 # long encoded as 32-bit int ('Y')
v = c1.get_long_mx40001
print_assert 'get_long_mx40001', v == -0x40001
v = c1.get_long_x40000
print_assert 'get_long_x40000', v == 0x40000
v = c1.get_long_mx80_000_000
print_assert 'get_long_mx80_000_000', v == -0x80_000_000
v = c1.get_long_x7f_fff_fff
print_assert 'get_long_x7f_fff_fff', v == 0x7f_fff_fff

# 0x5b # double 0.0
v = c1.get_double_0
print_assert 'get_double_0', v == 0.0

# 0x5c # double 1.0
v = c1.get_double_1
print_assert 'get_double_1', v == 1.0

# 0x5d # double represented as byte (-128.0 to 127.0)
v = c1.get_double_m128
print_assert 'get_double_m128', v == -128.0
v = c1.get_double_127
print_assert 'get_double_127', v == 127.0

# 0x5e # double represented as short (-32768.0 to 32767.0)
v = c1.get_double_m129
print_assert 'get_double_m129', v == -129.0
v = c1.get_double_128
print_assert 'get_double_128', v == 128.0
v = c1.get_double_m32768
print_assert 'get_double_m32768', v == -32768.0
v = c1.get_double_32767
print_assert 'get_double_32767', v == 32767.0

# 0x5f # double represented as float
# hessian2 write double-precision only

# 0x70..0x77 # fixed list with direct length
v = c1.get_list_size0
print_assert 'get_list_size0', v == []
v = c1.get_list_size7
print_assert 'get_list_size7', v == (1..7).to_a

# 0x78..0x7f # fixed untyped list with direct length
v = c1.get_untyped_list_size0
print_assert 'get_untyped_list_size0', v == []
v = c1.get_untyped_list_size7
print_assert 'get_untyped_list_size7', v == (1..7).to_a

# 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
v = c1.get_int_mx10
print_assert 'get_int_mx10', v == -0x10
v = c1.get_int_x3f
print_assert 'get_int_x3f', v == 0x3f

# 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
v = c1.get_int_mx11
print_assert 'get_int_mx11', v == -0x11
v = c1.get_int_x40
print_assert 'get_int_x40', v == 0x40
v = c1.get_int_mx800
print_assert 'get_int_mx800', v == -0x800
v = c1.get_int_x7ff
print_assert 'get_int_x7ff', v == 0x7ff

# 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
v = c1.get_int_mx801
print_assert 'get_int_mx801', v == -0x801
v = c1.get_int_x800
print_assert 'get_int_x800', v == 0x800
v = c1.get_int_mx40000
print_assert 'get_int_mx40000', v == -0x40000
v = c1.get_int_x3ffff
print_assert 'get_int_x3ffff', v == 0x3ffff

# 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
v = c1.get_long_mx8
print_assert 'get_long_mx8', v == -0x8
v = c1.get_long_xf
print_assert 'get_long_xf', v == 0xf

# 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
v = c1.get_long_mx9
print_assert 'get_long_mx9', v == -0x9
v = c1.get_long_x10
print_assert 'get_long_x10', v == 0x10
v = c1.get_long_mx800
print_assert 'get_long_mx800', v == -0x800
v = c1.get_long_x7ff
print_assert 'get_long_x7ff', v == 0x7ff
