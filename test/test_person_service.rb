# -*- encoding: utf-8 -*-

lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require ::File.expand_path('../profile', __FILE__)

# include Hessian2::Parser
# include Hessian2::Writer

# c1 = Hessian2::Client.new('http://127.0.0.1:9292/person')

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

# puts person
# puts null1.inspect
# puts true1
# puts false1
# puts int1
# puts wlong1
# puts long1
# puts double1
# puts date1
# puts str1
# puts hstr1.size
# puts list1
# puts rlist1
# puts map1
# puts rmap1
# puts bin1
# puts hbin1.size

# c1.multi_set(wperson,
#   [wperson, wperson],
#   [1 => wperson, 2 => wperson],
#   null1,
#   true1,
#   false1,
#   int1,
#   Hessian2::TypeWrapper.new('L', int1),
#   long1,
#   double1,
#   date1,
#   str1,
#   hstr1,
#   list1,
#   list1,
#   rlist1,
#   map1,
#   map1,
#   rmap1,
#   Hessian2::TypeWrapper.new('B', bin1),
#   Hessian2::TypeWrapper.new('B', hbin1))

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

c1 = Hessian2::Client.new('http://127.0.0.1:9001/person')

# # 0x00..0x1f # utf-8 string length 0-32 ok
# c1.set_string('金' * 32) 

# # 0x20..0x2f # binary data length 0-16 ok
# c1.set_bin(Hessian2::TypeWrapper.new('B', ([59.59] * 2).pack('G2'))) 

# # 0x30..0x33 # utf-8 string length 0-1023 ok
# c1.set_string('金' * 1023)

# # 0x34..0x37 # binary data length 0-1023 ok
# c1.set_bin(Hessian2::TypeWrapper.new('B', ['j' * 1023].pack('a*')))

# 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
# 0x41 # 8-bit binary data non-final chunk ('A')
# 0x42 # 8-bit binary data final chunk ('B')
# 0x43 # object type definition ('C')
# 0x44 # 64-bit IEEE encoded double ('D')
# 0x46 # boolean false ('F')
# 0x48 # untyped map ('H')
# 0x49 # 32-bit signed integer ('I')
# 0x4a # 64-bit UTC millisecond date
# 0x4b # 32-bit UTC minute date
# 0x4c # 64-bit signed long integer ('L')
# 0x4d # map with type ('M')
# 0x4e # null ('N')
# 0x4f # object instance ('O')
# 0x51 # reference to map/list/object - integer ('Q')
# 0x52 # utf-8 string non-final chunk ('R')
# 0x53 # utf-8 string final chunk ('S')
# 0x54 # boolean true ('T')
# 0x55 # variable-length list/vector ('U')
# 0x56 # fixed-length list/vector ('V')
# 0x57 # variable-length untyped list/vector ('W')
# 0x58 # fixed-length untyped list/vector ('X')
# 0x59 # long encoded as 32-bit int ('Y')
# 0x5b # double 0.0
# 0x5c # double 1.0
# 0x5d # double represented as byte (-128.0 to 127.0)
# 0x5e # double represented as short (-32768.0 to 327676.0)
# 0x5f # double represented as float
# 0x60..0x6f # object with direct type
# 0x70..0x77 # fixed list with direct length
# 0x78..0x7f # fixed untyped list with direct length
# 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
# 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
# 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
# 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
# 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)

# c1.set_null(nil)
# c1.set_true(true)
# c1.set_false(false)
# c1.set_int(59)
# c1.set_long(9876543210)
# c1.set_wlong(Hessian2::TypeWrapper.new('L', 59))
# c1.set_double(59.59)
# c1.set_date(Time.new)
# c1.set_hstring('金玉彬' * 30000)
# c1.set_list(['金玉彬', 'taka'])
# c1.set_map('金玉彬' => 1)

# c1.set_bin(Hessian2::TypeWrapper.new('B', IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__))))
# c1.set_person(Hessian2::TypeWrapper.new('example.Person', {name: '金玉彬', age: 18}))
