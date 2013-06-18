lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

MonkeyStruct = Struct.new(Monkey.to_s, :name, :age)

puts [].is_a? Array

monkey = Monkey.new
monkey.name = '阿门'
monkey.age = 7
monkey.description = '阿门啦啦啦'

arrbin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, monkey))
puts arrbin.inspect

smonkey = Hessian2.parse(arrbin, MonkeyStruct)
puts smonkey.inspect

monkey2 = Monkey.new
monkey2.name = '大鸡'
monkey2.age = 6
monkey2.description = '大鸡啦啦啦'

arrbin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, [monkey, monkey2]))
puts arrbin.inspect

smonkeys = Hessian2.parse(arrbin, [MonkeyStruct])
puts smonkeys.inspect