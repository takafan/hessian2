# -*- encoding: utf-8 -*-

lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require ::File.expand_path('../monkey_service', __FILE__)

# begin puts c1.undefined_method; rescue Hessian2::Fault => e; puts "#{e.message}"; end
# begin puts c1.multi_set; rescue Hessian2::Fault => e; puts "#{e.message}"; end

# person = c1.get_person
# wperson = Hessian2::TypeWrapper.new('example.Person', person)
# null1 = c1.get_null.inspect
# true1 = c1.get_true
# false1 = c1.get_false
# int1 = c1.get_int
# wlong1 = c1.get_wlong
# long1 = c1.get_long
# double1 = c1.get_double
# date1 = c1.get_date
# str1 = c1.get_string
# hstr1 = c1.get_hstring
# list1 = c1.get_list
# rlist1 = c1.get_rlist
# map1 = c1.get_map
# rmap1 = c1.get_rmap
# bin1 = c1.get_binary
# hbin1 = c1.get_hbinary

# t0 = Time.new
# arr = (1..10000).to_a
# puts c1.set_hlist(arr).size
# puts Time.new - t0

# c2 = Hessian2::Client.new('http://192.168.3.220:8100/passport/hessian/userProfileService')
# arr = (1..235).to_a
# t0 = Time.new
# profiles = c2.getProfileByUids(arr)
# puts "all: #{Time.new - t0}"
# puts profiles.size

# profiles = Profile.where(true).limit(200).map{|p| p.serializable_hash}
# puts profiles.class
# puts profiles.size
# enprofiles = reply_value(profiles)
# t0 = Time.new
# deprofiles = parse(enprofiles)
# puts "deprofiles: #{Time.new - t0}"
# puts deprofiles.size

c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')
list1 = [1, 2, 3 ,4, 5, 6, 7]
map1 = { name: '阿门', age: 7 }
map2 = { name: '大鸡', age: 6 }
monkey1 = Monkey.new(map1)
monkey2 = Monkey.new(map2)
tmonkey1 = Hessian2::TypeWrapper.new('example.Monkey', map1)
tmonkey2 = Hessian2::TypeWrapper.new('example.Monkey', map2)
cmonkey1 = Hessian2::ClassWrapper.new('example.Monkey', map1)
cmonkey2 = Hessian2::ClassWrapper.new('example.Monkey', map2)
monkeys = []
17.times do |i|
  monkeys << Hessian2::ClassWrapper.new("example.Monkey#{i}", map1)
end
monkeys << monkey1
now = Time.new

# 0x00..0x1f # utf-8 string length 0-31
c1.set_string_0('')
c1.set_string_x1f('j' * 0x1f)
c1.set_string_x1fu('金' * 0x1f)

# 0x20..0x2f # binary data length 0-15
c1.set_bin_0(Hessian2::TypeWrapper.new('B', ''))
c1.set_bin_xf(Hessian2::TypeWrapper.new('B', ['j' * 15].pack('a*')))

# 0x30..0x33 # utf-8 string length 0-1023
c1.set_string_x20('j' * 0x20)
c1.set_string_x20u('金' * 0x20)
c1.set_string_x3ff('j' * 0x3ff)
c1.set_string_x3ffu('金' * 0x3ff)

# 0x34..0x37 # binary data length 0-1023
c1.set_bin_x10(Hessian2::TypeWrapper.new('B', ['j' * 0x10].pack('a*')))
c1.set_bin_x3ff(Hessian2::TypeWrapper.new('B', ['j' * 0x3ff].pack('a*')))

# 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
c1.set_long_mx801(-0x801)
c1.set_long_x800(0x800)
c1.set_long_mx40000(-0x40000)
c1.set_long_x3ffff(0x3ffff)

# 0x41 # 8-bit binary data non-final chunk ('A')
c1.set_lighthouse(Hessian2::TypeWrapper.new('B', IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__))))

# 0x42 # 8-bit binary data final chunk ('B')
c1.set_bin_x400(Hessian2::TypeWrapper.new('B', ['j' * 0x400].pack('a*')))
c1.set_bin_x8000(Hessian2::TypeWrapper.new('B', ['j' * 0x8000].pack('a*')))

# 0x43 # object type definition ('C')
# 0x60..0x6f # object with direct type
c1.set_monkey_monkey(cmonkey1, cmonkey2)
c1.set_monkey_monkey(monkey1, monkey2)

# 0x44 # 64-bit IEEE encoded double ('D')
c1.set_double_min(4.9E-324)
c1.set_double_max(1.7976931348623157E308)

# 0x46 # boolean false ('F')
c1.set_false(false)

# 0x48 # untyped map ('H')
c1.set_map_h(map1)

# 0x49 # 32-bit signed integer ('I')
c1.set_int_mx40001(-0x40001)
c1.set_int_x40000(0x40000)
c1.set_int_mx40_000_000(-0x40_000_000)
c1.set_int_x3f_fff_fff(0x3f_fff_fff)


# 0x4a # 64-bit UTC millisecond date
c1.set_date(now)

# 0x4b # 32-bit UTC minute date
c1.set_date_min(Time.new(now.year, now.mon, now.day, now.hour, now.min))

# 0x4c # 64-bit signed long integer ('L')
c1.set_long_mx8_000_000_000_000_000(-0x8_000_000_000_000_000)
c1.set_long_x7_fff_fff_fff_fff_fff(0x7_fff_fff_fff_fff_fff)

# 0x4d # map with type ('M')
c1.set_monkey_monkey_t(tmonkey1, tmonkey2)

# 0x4e # null ('N')
c1.set_null(nil)

# 0x4f # object instance ('O')
begin c1.set_monkeys(monkeys); rescue Hessian2::Fault => e; puts "#{e.message}"; end

# 0x51 # reference to map/list/object - integer ('Q')
c1.set_map_list_monkey_map_list_monkey(map1, list1, cmonkey1, map1, list1, cmonkey1)

# 0x52 # utf-8 string non-final chunk ('R')
c1.set_string_x8001('j' * 0x8001)
c1.set_string_x8001u('金' * 0x8001)

# 0x53 # utf-8 string final chunk ('S')
c1.set_string_x400('j' * 0x400)
c1.set_string_x400u('金' * 0x400)
c1.set_string_x8000('j' * 0x8000)
c1.set_string_x8000u('金' * 0x8000)

# 0x54 # boolean true ('T')
c1.set_true(true)

# 0x55 # variable-length list/vector ('U')
# hessian2 write fixed-length list only

# 0x56 # fixed-length list/vector ('V')
c1.set_list(Hessian2::TypeWrapper.new('[int', list1 * 2))

# 0x57 # variable-length untyped list/vector ('W')
# hessian2 write fixed-length list only

# 0x58 # fixed-length untyped list/vector ('X')
c1.set_list(list1 * 2)

# 0x59 # long encoded as 32-bit int ('Y')
c1.set_long_mx40001(-0x40001)
c1.set_long_x40000(0x40000)
c1.set_long_mx80_000_000(-0x80_000_000)
c1.set_long_x7f_fff_fff(0x7f_fff_fff)

# 0x5b # double 0.0
c1.set_double_0(0.0)

# 0x5c # double 1.0
c1.set_double_1(1.0)

# 0x5d # double represented as byte (-128.0 to 127.0)
c1.set_double_mx80(-128.0)
c1.set_double_x7f(127.0)

# 0x5e # double represented as short (-32768.0 to 32767.0)
c1.set_double_mx8000(-32768.0)
c1.set_double_x7fff(32767.0)

# 0x5f # double represented as float
# hessian2 write double-precision only

# 0x70..0x77 # fixed list with direct length
c1.set_list_size0(Hessian2::TypeWrapper.new('[int', []))
c1.set_list_size7(Hessian2::TypeWrapper.new('[int', list1))

# 0x78..0x7f # fixed untyped list with direct length
c1.set_list_size0([])
c1.set_list_size7(list1)

# 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
c1.set_int_mx10(-0x10)
c1.set_int_x3f(0x3f)

# 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
c1.set_int_mx11(-0x11)
c1.set_int_x40(0x40)
c1.set_int_mx800(-0x800)
c1.set_int_x7ff(0x7ff)

# 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
c1.set_int_set_int_mx801(-0x801)
c1.set_int_x800(0x800)
c1.set_int_mx40000(-0x40000)
c1.set_int_x3ffff(0x3ffff)

# 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
c1.set_long_mx8(Hessian2::TypeWrapper.new('L', -0x8))
c1.set_long_xf(Hessian2::TypeWrapper.new('L', 0xf))

# 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
c1.set_long_mx9(Hessian2::TypeWrapper.new('L', -0x9))
c1.set_long_x10(Hessian2::TypeWrapper.new('L', 0x10))
c1.set_long_mx800(Hessian2::TypeWrapper.new('L', -0x800))
c1.set_long_x7ff(Hessian2::TypeWrapper.new('L', 0x7ff))
