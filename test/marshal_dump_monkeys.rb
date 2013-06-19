# -*- encoding: utf-8 -*-
require File.expand_path('../monkey',  __FILE__)

monkeys = Monkey.generate

t0 = Time.new
data =  Marshal.dump(monkeys)
puts "#{Time.new - t0}s"
puts "size: #{data.size}"
IO.binwrite('monkeys.marshal.data', data)
