# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

t0 = Time.new
Hessian2::Parser.parse(IO.binread('monkeys.bin'))
puts "#{Time.new - t0}s"
