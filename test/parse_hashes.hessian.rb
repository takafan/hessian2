# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

data = IO.binread('hashes.hessian.data')
t0 = Time.new
monkey = Hessian2.parse(data).last
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
puts monkey.inspect