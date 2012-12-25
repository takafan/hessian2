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

c3 = Hessian2::Client.new('http://127.0.0.1:9001/person')

#c3.set_null(nil)
#c3.set_true(true)
#c3.set_false(false)
#c3.set_int(59)
#c3.set_long(9876543210)
#c3.set_wlong(Hessian2::TypeWrapper.new('L', 59))
#c3.set_double(59.59)
#c3.set_date(Time.new)
#c3.set_string('金玉彬')
#c3.set_hstring('金玉彬' * 30000)
#c3.set_list(['金玉彬', 'taka'])
#c3.set_map('金玉彬' => 1)
#c3.set_bin(Hessian2::TypeWrapper.new('B', [59.59].pack('G')))
#c3.set_bin(Hessian2::TypeWrapper.new('B', IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__))))
#c3.set_person(Hessian2::TypeWrapper.new('example.Person', {name: '金玉彬', age: 18}))
