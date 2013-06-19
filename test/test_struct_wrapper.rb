lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

MonkeyStruct = Struct.new(Monkey.to_s, :name, :age)

monkey = Monkey.new
monkey.name = '阿门'
monkey.age = 7
monkey.description = '阿门啦啦啦'

monkey2 = Monkey.new
monkey2.name = '大鸡'
monkey2.age = 6
monkey2.description = '大鸡啦啦啦'

hash = {name: '阿门', age: 7, description: '阿门啦啦啦'}
hash2 = {name: '大鸡', age: 6, description: '大鸡啦啦啦'}

ahash = {'name' => '阿门', 'age' => 7, 'description' => '阿门啦啦啦'}
ahash2 = {'name' => '大鸡', 'age' => 6, 'description' => '大鸡啦啦啦'}

puts 'wrap monkey'

smonkeybin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, monkey))
puts smonkeybin.inspect

smonkey = Hessian2.parse(smonkeybin, MonkeyStruct)
puts smonkey.inspect

puts 'wrap hash'

shashbin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, hash))
puts shashbin.inspect

smonkey = Hessian2.parse(shashbin, MonkeyStruct)
puts smonkey.inspect

puts 'wrap ahash'

sahashbin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, ahash))
puts sahashbin.inspect

smonkey = Hessian2.parse(sahashbin, MonkeyStruct)
puts smonkey.inspect

puts 'wrap monkeys'

smonkeysbin = Hessian2.write(Hessian2::StructWrapper.new([MonkeyStruct], [monkey, monkey2]))
puts smonkeysbin.inspect

smonkeys = Hessian2.parse(smonkeysbin, [MonkeyStruct])
puts smonkeys.inspect

puts 'wrap hashes'

shashesbin = Hessian2.write(Hessian2::StructWrapper.new([MonkeyStruct], [hash, hash2]))
puts shashesbin.inspect

smonkey = Hessian2.parse(shashesbin, [MonkeyStruct])
puts smonkey.inspect

puts 'wrap ahashes'

sahashesbin = Hessian2.write(Hessian2::StructWrapper.new([MonkeyStruct], [ahash, ahash2]))
puts sahashesbin.inspect

smonkey = Hessian2.parse(sahashesbin, [MonkeyStruct])
puts smonkey.inspect
