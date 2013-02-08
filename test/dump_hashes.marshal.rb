# -*- encoding: utf-8 -*-
require File.expand_path('../monkey',  __FILE__)

monkeys = Monkey.generate_hash

t0 = Time.new
data =  Marshal.dump(monkeys)
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
IO.binwrite('hashes.marshal.data', data)
