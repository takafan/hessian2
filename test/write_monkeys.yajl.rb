# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'yajl'
require File.expand_path('../monkey',  __FILE__)

count = ARGV[0] ? ARGV[0].to_i : 100_000

monkeys = [].tap do |arr|
  count.times{|i| arr << Monkey.new(name: "阿门#{i}", age: 7) }
end

t0 = Time.new
data = Yajl::Encoder.encode(monkeys)
puts "#{Time.new - t0}s encode"
puts data.size


t0 = Time.new
val = Yajl::Parser.parse(data)
puts "#{Time.new - t0}s parse"
puts val.size
