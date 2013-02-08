# -*- encoding: utf-8 -*-
require 'msgpack'
require File.expand_path('../monkey',  __FILE__)

monkeys = Monkey.generate_hash

t0 = Time.new
data = monkeys.to_msgpack
puts "#{Time.new - t0}s"
puts data.size
IO.binwrite('hashes.msgpack.data', data)
