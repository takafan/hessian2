lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require File.expand_path('../monkey',  __FILE__)

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

aash = {'name' => '阿门', 'age' => 7, 'description' => '阿门啦啦啦'}
aash2 = {'name' => '大鸡', 'age' => 6, 'description' => '大鸡啦啦啦'}

MonkeyStruct = Struct.new(Monkey.to_s, :name, :age)

wmonkey = Hessian2::StructWrapper.new(MonkeyStruct, monkey)
whash = Hessian2::StructWrapper.new(MonkeyStruct, hash)
waash = Hessian2::StructWrapper.new(MonkeyStruct, aash)
wmonkeys = Hessian2::StructWrapper.new([MonkeyStruct], [monkey, monkey2])
whashes = Hessian2::StructWrapper.new([MonkeyStruct], [hash, hash2])
waashes = Hessian2::StructWrapper.new([MonkeyStruct], [aash, aash2])

puts 'wrap monkey'

monkeybin = Hessian2.write(wmonkey)
puts monkeybin.inspect

sonkey = Hessian2.parse(monkeybin, MonkeyStruct)
puts sonkey.inspect

puts 'wrap hash'

hashbin = Hessian2.write(whash)
puts hashbin.inspect

sonkey = Hessian2.parse(hashbin, MonkeyStruct)
puts sonkey.inspect

puts 'wrap aash'

aashbin = Hessian2.write(waash)
puts aashbin.inspect

sonkey = Hessian2.parse(aashbin, MonkeyStruct)
puts sonkey.inspect

puts 'wrap monkeys'

monkeysbin = Hessian2.write(wmonkeys)
puts monkeysbin.inspect

sonkeys = Hessian2.parse(monkeysbin, [MonkeyStruct])
puts sonkeys.inspect

puts 'wrap hashes'

hashesbin = Hessian2.write(whashes)
puts hashesbin.inspect

sonkeys = Hessian2.parse(hashesbin, [MonkeyStruct])
puts sonkeys.inspect

puts 'wrap aashes'

aashesbin = Hessian2.write(waashes)
puts aashesbin.inspect

sonkeys = Hessian2.parse(aashesbin, [MonkeyStruct])
puts sonkeys.inspect