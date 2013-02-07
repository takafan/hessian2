# -*- encoding: utf-8 -*-
require 'msgpack'
require File.expand_path('../monkey',  __FILE__)

data = IO.binread('monkeys.msgpack.bin')
t0 = Time.new
monkey = MessagePack.unpack(data).first
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
puts monkey.inspect
