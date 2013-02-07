# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

count = ARGV[0] ? ARGV[0].to_i : 100_000
monkeys = [].tap do |arr|
  count.times{|i| arr << Monkey.new(name: "阿门#{i}", age: 7)}
end
t0 = Time.new
bin = Hessian2::Writer.write_object(monkeys)
puts "#{Time.new - t0}s"
IO.binwrite('monkeys.bin', bin)
# t0 = Time.new
# data = Hessian2::Writer.write_object(monkeys)
# puts "#{Time.new - t0}s"
# puts data.size
