# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

c1 = Hessian2::Client.new('http://127.0.0.1:9292/monkey')

t0 = Time.new
50.times do 
  c1.get_date_20130112145959
end
puts "#{Time.new - t0}s"
