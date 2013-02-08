# -*- encoding: utf-8 -*-
require 'yajl'
require File.expand_path('../monkey',  __FILE__)

data = IO.binread('hashes.json.data')
t0 = Time.new
monkey = Yajl::Parser.parse(data).last
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
puts monkey.inspect
