# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

# c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')
# list1 = (1..7).to_a
# map1 = { name: '阿门', age: 7 }
# cmonkey1 = Hessian2::ClassWrapper.new('example.Monkey', map1)
# monkeys = []
# 0x11.times do |i|
#   monkeys << Hessian2::ClassWrapper.new("example.Monkey#{i}", map1)
# end
# now = Time.new(2013, 1, 12, 14, 59, 59)

# begin c1.undefined_method; rescue Hessian2::Fault => e; puts e.message; end

# begin c1.set_string_0('', 'undefined argument'); rescue Hessian2::Fault => e; puts e.message; end

# Hessian2.parse_bytes([0x5a].each)
monkey = Monkey.new(age: 1, name: 'a')
puts monkey.to_h