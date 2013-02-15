# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

class MonkeyService
  extend Hessian2::Handler
  
  # 0x00..0x1f # utf-8 string length 0-31
  def self.get_string_0
    ''
  end

  def self.get_string_x1f
    'j' * 0x1f
  end

  def self.get_string_x1fu
    '金' * 0x1f
  end
  
  def self.set_string_0(str1)
    print_assert 'set_string_0', str1 == ''
  end

  def self.set_string_x1f(str1)
    print_assert 'set_string_x1f', str1 == 'j' * 0x1f
  end

  def self.set_string_x1fu(str1)
    print_assert 'set_string_x1fu', str1 == '金' * 0x1f
  end
  
  # 0x20..0x2f # binary data length 0-15
  def self.get_bin_0
    Hessian2::TypeWrapper.new('B', '')
  end

  def self.get_bin_xf
    Hessian2::TypeWrapper.new('B', ['j' * 0xf].pack('a*'))
  end
  
  def self.set_bin_0(bin1)
    print_assert 'set_bin_0', bin1.size == 0
  end

  def self.set_bin_xf(bin1)
    print_assert 'set_bin_xf', bin1.size == 0xf
  end
  
  # 0x30..0x33 # utf-8 string length 0-1023
  def self.get_string_x20
    'j' * 0x20
  end

  def self.get_string_x20u
    '金' * 0x20
  end

  def self.get_string_x3ff
    'j' * 0x3ff
  end

  def self.get_string_x3ffu
    '金' * 0x3ff
  end
  
  def self.set_string_x20(str1)
    print_assert 'set_string_x20', str1[0] == 'j' && str1.size == 0x20
  end
  
  def self.set_string_x20u(str1)
    print_assert 'set_string_x20u', str1[0] == '金' && str1.size == 0x20
  end
  
  def self.set_string_x3ff(str1)
    print_assert 'set_string_x3ff', str1[0] == 'j' && str1.size == 0x3ff
  end
  
  def self.set_string_x3ffu(str1)
    print_assert 'set_string_x3ffu', str1[0] == '金' && str1.size == 0x3ff
  end
  
  # 0x34..0x37 # binary data length 0-1023
  def self.get_bin_x10
    Hessian2::TypeWrapper.new('B', ['j' * 0x10].pack('a*'))
  end

  def self.get_bin_x3ff
    Hessian2::TypeWrapper.new('B', ['j' * 0x3ff].pack('a*'))
  end
  
  def self.set_bin_x10(bin1)
    print_assert 'set_bin_x10', bin1.size == 0x10
  end
  
  def self.set_bin_x3ff(bin1)
    print_assert 'set_bin_x3ff', bin1.size == 0x3ff
  end
  
  # 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
  def self.get_long_mx801
    -0x801
  end

  def self.get_long_x800
    0x800
  end

  def self.get_long_mx40000
    -0x40000
  end

  def self.get_long_x3ffff
    0x3ffff
  end
  
  def self.set_long_mx801(long1)
    print_assert 'set_long_mx801', long1 == -0x801
  end
  
  def self.set_long_x800(long1)
    print_assert 'set_long_x800', long1 == 0x800
  end
  
  def self.set_long_mx40000(long1)
    print_assert 'set_long_mx40000', long1 == -0x40000
  end
  
  def self.set_long_x3ffff(long1)
    print_assert 'set_long_x3ffff', long1 == 0x3ffff
  end
  
  # 0x41 # 8-bit binary data non-final chunk ('A')
  def self.get_lighthouse
    Hessian2::TypeWrapper.new('B', IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__)))
  end
  
  def self.set_lighthouse(bin1) # 561276
    print_assert 'set_lighthouse', bin1.size == IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__)).size
  end
  
  # 0x42 # 8-bit binary data final chunk ('B')
  def self.get_bin_x400
    Hessian2::TypeWrapper.new('B', ['j' * 0x400].pack('a*'))
  end

  def self.get_bin_x8000
    Hessian2::TypeWrapper.new('B', ['j' * 0x8000].pack('a*'))
  end
  
  def self.set_bin_x400(bin1)
    print_assert 'set_bin_x400', bin1.size == 0x400
  end
  
  def self.set_bin_x8000(bin1)
    print_assert 'set_bin_x8000', bin1.size == 0x8000
  end
  
  # 0x43 # object type definition ('C') and 0x60..0x6f # object with direct type
  # 0x4d # map with type ('M')
  def self.get_monkey
    Monkey.new(name: '阿门', age: 7)
  end
  
  def self.set_monkey(monkey1)
    print_assert 'set_monkey', monkey1.name == '阿门' && monkey1.age == 7
  end
  
  # 0x44 # 64-bit IEEE encoded double ('D')
  def self.get_double_min
    4.9E-324
  end

  def self.get_double_max
    1.7976931348623157E308
  end

  def self.get_double_positive_infinity 
    Float::INFINITY
  end

  def self.get_double_negative_infinity
    -Float::INFINITY
  end

  def self.get_double_nan
    Float::NAN
  end

  def self.get_123dot456
    123.456
  end
  
  def self.set_double_min(double1) # 4.9E-324
    print_assert 'set_double_min', double1 == 4.9E-324
  end

  def self.set_double_max(double1) # 1.7976931348623157E308
    print_assert 'set_double_max', double1 == 1.7976931348623157E308
  end

  def self.set_double_positive_infinity(double1)
    print_assert 'set_double_positive_infinity', double1 == Float::INFINITY
  end
  
  def self.set_double_negative_infinity(double1)
    print_assert 'set_double_negative_infinity', double1 == -Float::INFINITY
  end
  
  def self.set_double_nan(double1)
    print_assert 'set_double_nan', double1.to_s.upcase == 'NAN'
  end
  
  def self.set_123dot456(double1)
    print_assert 'set_123dot456', double1 == 123.456
  end
  
  
  # 0x46 # boolean false ('F')
  def self.get_false
    false
  end
  
  def self.set_false(false1)
    print_assert 'set_false', !false1
  end
  
  # 0x48 # untyped map ('H')
  def self.get_map_h
    { name: '阿门', age: 7 }
  end
  
  def self.set_map_h(map1)
    print_assert 'set_map_h', map1['name'] == '阿门' && map1['age'] == 7
  end
  
  # 0x49 # 32-bit signed integer ('I')
  def self.get_int_mx40001
    -0x40001
  end

  def self.get_int_x40000
    0x40000
  end

  def self.get_int_mx40_000_000
    -0x40_000_000
  end

  def self.get_int_x3f_fff_fff
    0x3f_fff_fff
  end
  
  def self.set_int_mx40001(int1)
    print_assert 'set_int_mx40001', int1 == -0x40001
  end
  
  def self.set_int_x40000(int1)
    print_assert 'set_int_x40000', int1 == 0x40000
  end
  
  def self.set_int_mx40_000_000(int1)
    print_assert 'set_int_mx40_000_000', int1 == -0x40_000_000
  end
  
  def self.set_int_x3f_fff_fff(int1)
    print_assert 'set_int_x3f_fff_fff', int1 == 0x3f_fff_fff
  end
  
  # 0x4a # 64-bit UTC millisecond date
  def self.get_date_20130112145959
    Time.new(2013, 1, 12, 14, 59, 59)
  end
  
  def self.set_date_20130112145959(date1)
    print_assert 'set_date_20130112145959', date1 == Time.new(2013, 1, 12, 14, 59, 59)
  end
  
  # 0x4b # 32-bit UTC minute date
  def self.get_date_201301121459
    Time.new(2013, 1, 12, 14, 59, 0)
  end
  
  def self.set_date_201301121459(date1)
    print_assert 'set_date_201301121459', date1 == Time.new(2013, 1, 12, 14, 59, 0)
  end
  
  # 0x4c # 64-bit signed long integer ('L')
  def self.get_long_mx80_000_001
    -0x80_000_001
  end

  def self.get_long_x80_000_000
    0x80_000_000
  end

  def self.get_long_mx8_000_000_000_000_000
    -0x8_000_000_000_000_000
  end

  def self.get_long_x7_fff_fff_fff_fff_fff
    0x7_fff_fff_fff_fff_fff
  end
  
  def self.set_long_mx80_000_001(long1)
    print_assert 'set_long_mx80_000_001', long1 == -0x80_000_001
  end
  
  def self.set_long_x80_000_000(long1)
    print_assert 'set_long_x80_000_000', long1 == 0x80_000_000
  end
  
  def self.set_long_mx8_000_000_000_000_000(long1)
    print_assert 'set_long_mx8_000_000_000_000_000', long1 == -0x8_000_000_000_000_000
  end
  
  def self.set_long_x7_fff_fff_fff_fff_fff(long1)
    print_assert 'set_long_x7_fff_fff_fff_fff_fff', long1 == 0x7_fff_fff_fff_fff_fff
  end
  
  # 0x4d # map with type ('M')
  def self.get_map
    Hessian2::TypeWrapper.new('example.Monkey', self.get_map_h)
  end

  def self.set_map(map1)
    print_assert 'set_map', map1.name == '阿门' && map1.age == 7
  end
  
  # 0x4e # null ('N')
  def self.get_null
    nil
  end
  
  def self.set_null(obj)
    print_assert 'set_null', obj.nil?
  end
  
  # 0x4f # object instance ('O')
  def self.get_monkeys
    [ Monkey.new(name: '阿门', age: 7), Monkey.new(name: '大鸡', age: 6) ]
  end
  
  def self.set_monkeys(monkeys)
    print_assert 'set_monkeys', monkeys.size == 0x11
  end
  
  # 0x51 # reference to map/list/object - integer ('Q')
  def self.get_map_h_map_h
    map1 = self.get_map_h
    [ map1, map1 ]
  end

  def self.get_direct_untyped_list_list
    list1 = self.get_list_size7
    [ list1, list1 ]
  end

  def self.get_untyped_list_list
    self.get_list_list
  end

  def self.get_direct_list_list
    list1 = self.get_list_size7
    [ list1, list1 ]
  end

  def self.get_list_list
    list1 = self.get_list
    [ list1, list1 ]
  end

  def self.get_monkey_monkey
    monkey = Monkey.new(name: '阿门', age: 7)
    [ monkey, monkey ]
  end
  
  def self.set_map_list_monkey_map_list_monkey(map1, list1, monkey1, map2, list2, monkey2)
    print_assert 'set_map_list_monkey_map_list_monkey', map1['name'] == map2['name'] && list1[0] == list2[0] && monkey1.name == monkey2.name
  end
  
  # 0x52 # utf-8 string non-final chunk ('R')
  def self.get_string_x8001
    'j' * 0x8001
  end

  def self.get_string_x8001u
    '金' * 0x8001
  end
  
  def self.set_string_x8001(str1)
    print_assert 'set_string_x8001', str1[0] == 'j' && str1.size == 0x8001
  end
  
  def self.set_string_x8001u(str1)
    print_assert 'set_string_x8001u', str1[0] == '金' && str1.size == 0x8001
  end
  
  # 0x53 # utf-8 string final chunk ('S')
  def self.get_string_x400
    'j' * 0x400
  end

  def self.get_string_x400u
    '金' * 0x400
  end

  def self.get_string_x8000
    'j' * 0x8000
  end

  def self.get_string_x8000u
    '金' * 0x8000
  end
  
  def self.set_string_x400(str1)
    print_assert 'set_string_x400', str1[0] == 'j' && str1.size == 0x400
  end
  
  def self.set_string_x400u(str1)
    print_assert 'set_string_x400u', str1[0] == '金' && str1.size == 0x400
  end
  
  def self.set_string_x8000(str1)
    print_assert 'set_string_x8000', str1[0] == 'j' && str1.size == 0x8000
  end
  
  def self.set_string_x8000u(str1)
    print_assert 'set_string_x8000u', str1[0] == '金' && str1.size == 0x8000
  end
  
  # 0x54 # boolean true ('T')
  def self.get_true
    true
  end
  
  def self.set_true(true1)
    print_assert 'set_true', true1
  end
  
  # 0x56 # fixed-length list/vector ('V')
  # 0x58 # fixed-length untyped list/vector ('X')
  def self.get_list
    self.get_list_size7 * 2
  end
  
  def self.get_untyped_list
    self.get_list
  end
  
  def self.set_list(list1)
    print_assert 'set_list', list1.size == 14 && list1[0] == 1
  end

  def self.set_list_int(list1)
    print_assert 'set_list_int', list1.size == 14 && list1[0] == 1
  end

  def self.set_list_monkey(list1)
    print_assert 'set_list_monkey', list1.size == 14 && list1.last.name == '阿门' && list1.last.age == 7
  end
  
  # 0x59 # long encoded as 32-bit int ('Y')
  def self.get_long_mx40001
    -0x40001
  end

  def self.get_long_x40000
    0x40000
  end

  def self.get_long_mx80_000_000
    -0x80_000_000
  end

  def self.get_long_x7f_fff_fff
    0x7f_fff_fff
  end
  
  def self.set_long_mx40001(long1)
    print_assert 'set_long_mx40001', long1 == -0x40001
  end
  
  def self.set_long_x40000(long1)
    print_assert 'set_long_x40000', long1 == 0x40000
  end
  
  def self.set_long_mx80_000_000(long1)
    print_assert 'set_long_mx80_000_000', long1 == -0x80_000_000
  end
  
  def self.set_long_x7f_fff_fff(long1)
    print_assert 'set_long_x7f_fff_fff', long1 == 0x7f_fff_fff
  end
  
  # 0x5b # double 0.0
  def self.get_double_0
    0.0
  end
  
  def self.set_double_0(double1)
    print_assert 'set_double_0', double1 == 0.0
  end
  
  # 0x5c # double 1.0
  def self.get_double_1
    1.0
  end
  
  def self.set_double_1(double1)
    print_assert 'set_double_1', double1 == 1.0
  end
  
  # 0x5d # double represented as byte (-128.0 to 127.0)
  def self.get_double_m128
    -128.0
  end

  def self.get_double_127
    127.0
  end
  
  def self.set_double_m128(double1)
    print_assert 'set_double_m128', double1 == -128.0
  end

  def self.set_double_127(double1)
    print_assert 'set_double_127', double1 == 127.0
  end
  
  # 0x5e # double represented as short (-32768.0 to 32767.0)
  def self.get_double_m129
    -129.0
  end

  def self.get_double_128
    128.0
  end

  def self.get_double_m32768
    -32768.0
  end

  def self.get_double_32767
    32767.0
  end
  
  def self.set_double_m129(double1)
    print_assert 'set_double_m129', double1 == -129.0
  end
  
  def self.set_double_128(double1)
    print_assert 'set_double_128', double1 == 128.0
  end
  
  def self.set_double_m32768(double1)
    print_assert 'set_double_m32768', double1 == -32768.0
  end
  
  def self.set_double_32767(double1)
    print_assert 'set_double_32767', double1 == 32767.0
  end
  
  # 0x70..0x77 # fixed list with direct length 
  # 0x78..0x7f # fixed untyped list with direct length
  def self.get_list_size0
    []
  end

  def self.get_list_size7
    (1..7).to_a
  end

  def self.get_untyped_list_size0
    self.get_list_size0
  end

  def self.get_untyped_list_size7
    self.get_list_size7
  end
  
  def self.set_list_size0(list1)
    print_assert 'set_list_size0', list1.size == 0
  end
  
  def self.set_list_size7(list1)
    print_assert 'set_list_size7', list1.size == 7 && list1[0] == 1
  end
  
  # 0x80..0xbf # one-octet compact int (-x10 to x2f, x90 is 0)
  def self.get_int_mx10
    -0x10
  end

  def self.get_int_x3f
    0x3f
  end
  
  def self.set_int_mx10(int1)
    print_assert 'set_int_mx10', int1 == -0x10
  end

  def self.set_int_x3f(int1)
    print_assert 'set_int_x3f', int1 == 0x3f
  end
  
  # 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
  def self.get_int_mx11
    -0x11
  end

  def self.get_int_x40
    0x40
  end

  def self.get_int_mx800
    -0x800
  end

  def self.get_int_x7ff
    0x7ff
  end
  
  def self.set_int_mx11(int1)
    print_assert 'set_int_mx11', int1 == -0x11
  end

  def self.set_int_x40(int1)
    print_assert 'set_int_x40', int1 == 0x40
  end

  def self.set_int_mx800(int1)
    print_assert 'set_int_mx800', int1 == -0x800
  end

  def self.set_int_x7ff(int1)
    print_assert 'set_int_x7ff', int1 == 0x7ff
  end
  
  # 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
  def self.get_int_mx801
    -0x801
  end

  def self.get_int_x800
    0x800
  end

  def self.get_int_mx40000
    -0x40000
  end

  def self.get_int_x3ffff
    0x3ffff
  end
  
  def self.set_int_mx801(int1)
    print_assert 'set_int_mx801', int1 == -0x801
  end

  def self.set_int_x800(int1)
    print_assert 'set_int_x800', int1 == 0x800
  end

  def self.set_int_mx40000(int1)
    print_assert 'set_int_mx40000', int1 == -0x40000
  end

  def self.set_int_x3ffff(int1)
    print_assert 'set_int_x3ffff', int1 == 0x3ffff
  end
  
  # 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
  def self.get_long_mx8
    -0x8
  end

  def self.get_long_xf
    0xf
  end
  
  def self.set_long_mx8(long1)
    print_assert 'set_long_mx8', long1 == -0x8
  end

  def self.set_long_xf(long1)
    print_assert 'set_long_xf', long1 == 0xf
  end
  
  # 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
  def self.get_long_mx9
    -0x9
  end

  def self.get_long_x10
    0x10
  end

  def self.get_long_mx800
    -0x800
  end

  def self.get_long_x7ff
    0x7ff
  end
  
  def self.set_long_mx9(long1)
    print_assert 'set_long_mx9', long1 == -0x9
  end

  def self.set_long_x10(long1)
    print_assert 'set_long_x10', long1 == 0x10
  end

  def self.set_long_mx800(long1)
    print_assert 'set_long_mx800', long1 == -0x800
  end

  def self.set_long_x7ff(long1)
    print_assert 'set_long_x7ff', long1 == 0x7ff
  end

  private
  def self.print_assert(method, t)
    puts "#{t ? '.' : '*' * 10 << 'fail'} #{method}"
  end

end
