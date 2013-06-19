# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

c1 = Hessian2::Client.new("http://#{ARGV[1] || '127.0.0.1'}:4567/monkey")

puts c1.wait_taka(ARGV[0] || 'taka')
