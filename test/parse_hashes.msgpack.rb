# -*- encoding: utf-8 -*-
require 'msgpack'
require File.expand_path('../monkey',  __FILE__)

data = IO.binread('hashes.msgpack.data')
t0 = Time.new
monkey = MessagePack.unpack(data).last
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
puts monkey.inspect
