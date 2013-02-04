# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')

t0 = Time.new
data = c1.get_a_batch_of_monkeys(1000)
puts "#{Time.new - t0}s"
puts data.size
