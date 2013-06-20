lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)

require 'hessian2'
require File.expand_path('../another_monkey',  __FILE__)
require File.expand_path('../establish_connection',  __FILE__)
require File.expand_path('../monkey',  __FILE__)

hash = { born_at: Time.new(2005, 3, 4), name: '阿门', price: 59.59 }
hash2 = { born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

monkey = Monkey.new(hash)
monkey2 = Monkey.new(hash2)

aash = monkey.attributes
aash2 = monkey2.attributes

aonkey = AnotherMonkey.new(hash)
aonkey2 = AnotherMonkey.new(hash2)

whash = Hessian2::StructWrapper.new(MonkeyStruct, hash)
wmonkey = Hessian2::StructWrapper.new(MonkeyStruct, monkey)
waash = Hessian2::StructWrapper.new(MonkeyStruct, aash)
waonkey = Hessian2::StructWrapper.new(MonkeyStruct, aonkey)

whashes = Hessian2::StructWrapper.new([MonkeyStruct], [hash, hash2])
wmonkeys = Hessian2::StructWrapper.new([MonkeyStruct], [monkey, monkey2])
waashes = Hessian2::StructWrapper.new([MonkeyStruct], [aash, aash2])
waonkeys = Hessian2::StructWrapper.new([MonkeyStruct], [aonkey, aonkey2])

puts 'wrap hash'

hashbin = Hessian2.write(whash)
puts hashbin.inspect

sonkey = Hessian2.parse(hashbin, MonkeyStruct)
puts sonkey.inspect

puts 'wrap monkey'

monkeybin = Hessian2.write(wmonkey)
puts monkeybin.inspect

sonkey = Hessian2.parse(monkeybin, MonkeyStruct)
puts sonkey.inspect

puts 'wrap aash'

aashbin = Hessian2.write(waash)
puts aashbin.inspect

sonkey = Hessian2.parse(aashbin, MonkeyStruct)
puts sonkey.inspect

puts 'wrap aonkey'

aonkeybin = Hessian2.write(waonkey)
puts aonkeybin.inspect

sonkey = Hessian2.parse(aonkeybin, MonkeyStruct)
puts sonkey.inspect

puts 'wrap hashes'

hashesbin = Hessian2.write(whashes)
puts hashesbin.inspect

sonkeys = Hessian2.parse(hashesbin, [MonkeyStruct])
puts sonkeys.inspect

puts 'wrap monkeys'

monkeysbin = Hessian2.write(wmonkeys)
puts monkeysbin.inspect

sonkeys = Hessian2.parse(monkeysbin, [MonkeyStruct])
puts sonkeys.inspect

puts 'wrap aashes'

aashesbin = Hessian2.write(waashes)
puts aashesbin.inspect

sonkeys = Hessian2.parse(aashesbin, [MonkeyStruct])
puts sonkeys.inspect

puts 'wrap aonkeys'

aonkeysbin = Hessian2.write(waonkeys)
puts aonkeysbin.inspect

sonkeys = Hessian2.parse(aonkeysbin, [MonkeyStruct])
puts sonkeys.inspect
