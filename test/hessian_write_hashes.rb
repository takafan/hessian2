# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

monkeys = Monkey.generate_hash

t0 = Time.new
data = Hessian2.write(monkeys)
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
IO.binwrite('hashes.hessian.data', data)
