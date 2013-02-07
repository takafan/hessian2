# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

data = IO.binread('monkeys.hessian.bin')
t0 = Time.new
monkey = Hessian2::Parser.parse(data).first
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
puts monkey.inspect
