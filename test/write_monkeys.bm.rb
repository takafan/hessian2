# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')

count = ARGV[0] ? ARGV[0].to_i : 100_000

monkeys = [Monkey.new(name: '阿门', age: 7)] * count

t0 = Time.new
data = Hessian2::Writer.write_object(monkeys)
puts "#{Time.new - t0}s"
puts data.size
