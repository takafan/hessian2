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

wmonkey = Hessian2::ClassWrapper.new('example.Monkey', monkey)
whash = Hessian2::ClassWrapper.new('example.Monkey', hash)
waash = Hessian2::ClassWrapper.new('example.Monkey', aash)
wmonkeys = Hessian2::ClassWrapper.new('[example.Monkey', [monkey, monkey2])
whashes = Hessian2::ClassWrapper.new('[example.Monkey', [hash, hash2])
waashes = Hessian2::ClassWrapper.new('[example.Monkey', [aash, aash2])

puts 'wrap monkey'

monkeybin = Hessian2.write(wmonkey)
puts monkeybin.inspect

sonkey = Hessian2.parse(monkeybin)
puts sonkey.inspect

puts 'wrap hash'

hashbin = Hessian2.write(whash)
puts hashbin.inspect

sonkey = Hessian2.parse(hashbin)
puts sonkey.inspect

puts 'wrap aash'

aashbin = Hessian2.write(waash)
puts aashbin.inspect

sonkey = Hessian2.parse(aashbin)
puts sonkey.inspect

puts 'wrap monkeys'

monkeysbin = Hessian2.write(wmonkeys)
puts monkeysbin.inspect

sonkeys = Hessian2.parse(monkeysbin)
puts sonkeys.inspect

puts 'wrap hashes'

hashesbin = Hessian2.write(whashes)
puts hashesbin.inspect

sonkeys = Hessian2.parse(hashesbin)
puts sonkeys.inspect

puts 'wrap aashes'

aashesbin = Hessian2.write(waashes)
puts aashesbin.inspect

sonkeys = Hessian2.parse(aashesbin)
puts sonkeys.inspect
