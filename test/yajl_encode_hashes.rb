# -*- encoding: utf-8 -*-
require 'yajl'
require File.expand_path('../monkey',  __FILE__)

monkeys = Monkey.generate_hash

t0 = Time.new
data = Yajl::Encoder.encode(monkeys)
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
IO.binwrite('hashes.json.data', data)
