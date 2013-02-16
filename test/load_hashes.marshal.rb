# -*- encoding: utf-8 -*-
require File.expand_path('../monkey',  __FILE__)

data = IO.binread('hashes.marshal.data')
t0 = Time.new
monkey = Marshal.load(data).last
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
puts monkey.inspect