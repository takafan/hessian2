# -*- encoding: utf-8 -*-
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

class MonkeyService
  include Hessian2::Handler

  def get_monkey
    Monkey.new(age: 3, name: '塔卡')
  end

  def get_null
    nil
  end

  def get_true
    true
  end

  def get_false
    false
  end

  def get_int
    59
  end

  def get_wlong
    Hessian2::TypeWrapper.new('L', get_int)
  end

  def get_long
    9876543210
  end

  def get_double
    59.59
  end

  def get_date
    Time.new
  end

  def get_string
    '金玉彬'
  end

  def get_hstring
    get_string * 32769
  end

  def get_list
    ['a', 'b']
  end

  def get_rlist
    a = get_list
    [a, a]
  end

  def set_hlist(hlist)
    hlist
  end

  def get_map
    {a: 1, 'b' => 2}
  end

  def get_rmap
    h = get_map
    [h, h]
  end

  def get_binary
    Hessian2::TypeWrapper.new('B', [59.59].pack('G'))
  end

  def get_hbinary
    Hessian2::TypeWrapper.new('B', IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__)))
  end

  def multi_set(person,
    personlist,
    personmap,
    null1,
    true1,
    false1,
    int1,
    wlong1,
    long1,
    double1,
    date1,
    str1,
    hstr1,
    list1,
    list1r,
    rlist1,
    map1,
    map1r,
    rmap1,
    bin1, 
    hbin1)

    IO.write(File.expand_path("../#{Time.new.to_i}.txt", __FILE__), hstr1)
    IO.binwrite(File.expand_path("../#{Time.new.to_i}.bin", __FILE__), hbin1)

    puts person
    puts personlist
    puts personmap
    puts null1.inspect
    puts true1
    puts false1
    puts int1
    puts wlong1
    puts long1
    puts double1
    puts date1
    puts str1
    puts hstr1.size
    puts list1
    puts list1r
    puts rlist1
    puts map1
    puts map1r
    puts rmap1
    puts bin1
    puts hbin1.size

    nil
  end

  def print_assert(method, t)
    puts "#{t ? '.' : 'fail'} #{method}"
  end

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
    print_assert 'set_string_x1f', str1 == '金' * 0x1f
  end
  
  # 0x20..0x2f # binary data length 0-15
  def self.get_bin_0
    Hessian2::TypeWrapper.new('B', '')
  end

  def self.get_bin_xf
    Hessian2::TypeWrapper.new('B', ['j' * 0xf].pack('a*'))
  end
  
  def self.set_bin_0(bin1)
  end

  def self.set_bin_xf(bin1)
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
  
  def self.set_string_x20(str1);
  def self.set_string_x20u(str1);
  def self.set_string_x3ff(str1);
  def self.set_string_x3ffu(str1);
  
  # 0x34..0x37 # binary data length 0-1023
  def self.get_bin_x10
    Hessian2::TypeWrapper.new('B', ['j' * 0x10].pack('a*'))
  end

  def self.get_bin_x3ff
    Hessian2::TypeWrapper.new('B', ['j' * 0x3ff].pack('a*'))
  end
  
  def self.set_bin_x10(bin1);
  def self.set_bin_x3ff(bin1);
  
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
  
  def self.set_long_mx801(long1);
  def self.set_long_x800(long1);
  def self.set_long_mx40000(long1);
  def self.set_long_x3ffff(long1);
  
  # 0x41 # 8-bit binary data non-final chunk ('A')
  def self.get_lighthouse
    Hessian2::TypeWrapper.new('B', IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__)))
  end
  
  def self.set_lighthouse(bin1); #561276
  
  # 0x42 # 8-bit binary data final chunk ('B')
  def self.get_bin_x400
    Hessian2::TypeWrapper.new('B', ['j' * 0x400].pack('a*'))
  end

  def self.get_bin_x8000
    Hessian2::TypeWrapper.new('B', ['j' * 0x8000].pack('a*'))
  end
  
  def self.set_bin_x400(bin1);
  def self.set_bin_x8000(bin1);
  
  # 0x43 # object type definition ('C') and 0x60..0x6f # object with direct type
  # 0x4d # map with type ('M')
  def self.get_monkey
    Monkey.new(name: '阿门', age: 7)
  end
  
  def self.set_monkey(monkey1);
  
  # 0x44 # 64-bit IEEE encoded double ('D')
  def self.get_double_min
    4.9E-324
  end

  def self.get_double_max
    1.7976931348623157E308
  end
  
  def self.set_double_min(double1); # 4.9E-324
  def self.set_double_max(double1); # 1.7976931348623157E308
  
  # 0x46 # boolean false ('F')
  def self.get_false
    false
  end
  
  def self.set_false(false1);
  
  # 0x48 # untyped map ('H')
  def self.get_map_h
    { name: '阿门', age: 7 }
  end
  
  def self.set_map_h(map1);
  
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
  
  def self.set_int_mx40001(int1);
  def self.set_int_x40000(int1);
  def self.set_int_mx40_000_000(int1);
  def self.set_int_x3f_fff_fff(int1);
  
  # 0x4a # 64-bit UTC millisecond date
  def self.get_date_20130112145959
    Time.new(2013, 1, 12, 14, 59, 59)
  end
  
  def self.set_date_20130112145959(date1);
  
  # 0x4b # 32-bit UTC minute date
  def self.get_date_201301121459
    Time.new(2013, 1, 12, 14, 59, 0)
  end
  
  def self.set_date_201301121459(date1);
  
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
  
  def self.set_long_mx80_000_001(long1);
  def self.set_long_x80_000_000(long1);
  def self.set_long_mx8_000_000_000_000_000(long1);
  def self.set_long_x7_fff_fff_fff_fff_fff(long1);
  
  # 0x4d # map with type ('M')
  def self.get_map
    Hessian2::TypeWrapper.new('example.Monkey', self.get_map_h)
  end

  def self.set_map(map1);
  
  # 0x4e # null ('N')
  def self.get_null
    nil
  end
  
  def self.set_null(obj);
  
  # 0x4f # object instance ('O')
  def self.get_monkeys
    Monkey.new(name: '阿门', age: 7), Monkey.new(name: '大鸡', age: 6)
  end
  
  def self.set_monkeys(monkeys);
  
  # 0x51 # reference to map/list/object - integer ('Q')
  def self.get_map_h_map_h
    map1 = self.get_map_h
    map1, map1
  end

  def self.get_direct_untyped_list_list
    list1 = self.get_list_size7
    list1, list1
  end

  def self.get_untyped_list_list
    list1 = self.get_list
    list1, list1
  end

  def self.get_direct_list_list();
  def self.get_list_list();
  def self.get_monkey_monkey();
  
  def self.set_map_list_monkey_map_list_monkey(map1, list1, monkey1, 
    map2, list2, monkey2);
  
  # 0x52 # utf-8 string non-final chunk ('R')
  def self.get_string_x8001();
  def self.get_string_x8001u();
  
  def self.set_string_x8001(String str1);
  def self.set_string_x8001u(String str1);
  
  # 0x53 # utf-8 string final chunk ('S')
  def self.get_string_x400();
  def self.get_string_x400u();
  def self.get_string_x8000();
  def self.get_string_x8000u();
  
  def self.set_string_x400(String str1);
  def self.set_string_x400u(String str1);
  def self.set_string_x8000(String str1);
  def self.set_string_x8000u(String str1);
  
  # 0x54 # boolean true ('T')
  def self.get_true();
  
  def self.set_true(boolean true1);
  
  # 0x56 # fixed-length list/vector ('V')
  # 0x58 # fixed-length untyped list/vector ('X')
  def self.get_list();
  def self.get_untyped_list();
  
  def self.set_list(int[] list1);
  
  # 0x59 # long encoded as 32-bit int ('Y')
  def self.get_long_mx40001();
  def self.get_long_x40000();
  def self.get_long_mx80_000_000();
  def self.get_long_x7f_fff_fff();
  
  def self.set_long_mx40001(long long1);
  def self.set_long_x40000(long long1);
  def self.set_long_mx80_000_000(long long1);
  def self.set_long_x7f_fff_fff(long long1);
  
  # 0x5b # double 0.0
  def self.get_double_0();
  
  def self.set_double_0(double double1);
  
  # 0x5c # double 1.0
  def self.get_double_1();
  
  def self.set_double_1(double double1);
  
  # 0x5d # double represented as byte (-128.0 to 127.0)
  def self.get_double_m128();
  def self.get_double_127();
  
  def self.set_double_m128(double double1);
  def self.set_double_127(double double1);
  
  # 0x5e # double represented as short (-32768.0 to 32767.0)
  def self.get_double_m129();
  def self.get_double_128();
  def self.get_double_m32768();
  def self.get_double_32767();
  
  def self.set_double_m129(double double1);
  def self.set_double_128(double double1);
  def self.set_double_m32768(double double1);
  def self.set_double_32767(double double1);
  
  # 0x70..0x77 # fixed list with direct length 
  # 0x78..0x7f # fixed untyped list with direct length
  def self.get_list_size0();
  def self.get_list_size7();
  def self.get_untyped_list_size0();
  def self.get_untyped_list_size7();
  
  def self.set_list_size0(int[] list1);
  def self.set_list_size7(int[] list1);
  
  # 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
  def self.get_int_mx10();
  def self.get_int_x3f();
  
  def self.set_int_mx10(int int1);
  def self.set_int_x3f(int int1);
  
  # 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
  def self.get_int_mx11();
  def self.get_int_x40();
  def self.get_int_mx800();
  def self.get_int_x7ff();
  
  def self.set_int_mx11(int int1);
  def self.set_int_x40(int int1);
  def self.set_int_mx800(int int1);
  def self.set_int_x7ff(int int1);
  
  # 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
  def self.get_int_mx801();
  def self.get_int_x800();
  def self.get_int_mx40000();
  def self.get_int_x3ffff();
  
  def self.set_int_mx801(int int1);
  def self.set_int_x800(int int1);
  def self.set_int_mx40000(int int1);
  def self.set_int_x3ffff(int int1);
  
  # 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
  def self.get_long_mx8();
  def self.get_long_xf();
  
  def self.set_long_mx8(long long1);
  def self.set_long_xf(long long1);
  
  # 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
  def self.get_long_mx9();
  def self.get_long_x10();
  def self.get_long_mx800();
  def self.get_long_x7ff();
  
  def self.set_long_mx9(long long1);
  def self.set_long_x10(long long1);
  def self.set_long_mx800(long long1);
  def self.set_long_x7ff(long long1);

end
