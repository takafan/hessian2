# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')

count = ARGV[0] ? ARGV[0].to_i : 100

t0 = Time.new
count.times do
  c1.get_string_x8000u
end
puts "#{Time.new - t0}s"
