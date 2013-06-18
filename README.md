# hessian2

like json, additionally, 麻绳2 support structured data, with no schema.

hessian2 implements hessian 2.0 protocol. check [web services protocol](http://hessian.caucho.com/doc/hessian-ws.html) and [serialization protocol](http://hessian.caucho.com/doc/hessian-serialization.html).

## comparing

yajl-ruby: json, fast.

msgpack: binary, faster.

protobuf: encoding structured data with schema.

marshal: fast, powerful, but ruby only.

hessian2: clean api as marshal, write smaller than pack, support object, parse it to struct.

## install

```
gem install hessian2
```

```
require 'hessian2'
```

## serializing

``` ruby
bin = Hessian2.write(obj)
```

## deserializing 

``` ruby
obj = Hessian2.parse(bin)
```

## struct wrapper, for hash and object, only send values that specified

writing a monkey to array-binary

``` ruby
wmonkey = Hessian2::StructWrapper.new(Struct.new(:name, :age), monkey)
bin = Hessian2.write(wmonkey)
```

parsing array-binary to a monkey struct

``` ruby
smonkey = Hessian2.parse(bin, Struct.new(:name, :age))
```

monkeys

``` ruby
wmonkeys = Hessian2::StructWrapper.new([Struct.new(:name, :age)], monkeys)
bin = Hessian2.write(wmonkeys)

smonkeys = Hessian2.parse(bin, [Struct.new(:name, :age)])
```

struct wrapper support: hash, object, [hash, [object

## class wrapper, for statically typed languages

wrap a hash to a monkey

``` ruby
hash = {name: '阿门', age: 7}
wmonkey = Hessian2::ClassWrapper.new('com.hululuu.Monkey', hash)
```

class wrapper support: hash, object, [hash, [object

## type wrapper

wrap a string to long

``` ruby
str = '-0x8_000_000_000_000_000'
heslong = Hessian2::TypeWrapper.new('L', str)
```

wrap a file to binary

``` ruby
binstr = IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__))
hesbin = Hessian2::TypeWrapper.new('B', binstr)
```

wrap a batch of files

``` ruby
arr = [binstr1, binstr2]
hesbin = Hessian2::TypeWrapper.new('[B', arr))
```

## client

``` ruby
url = 'http://127.0.0.1:9292/monkey'
client = Hessian2::Client.new(url)
```

call remote method, send a monkey

``` ruby
monkey = Monkey.new(name: '阿门', age: 7)
client.send_monkey(monkey)
```

## service

extend hessian handler

``` ruby
class MonkeyService
  extend Hessian2::Handler

  def self.send_monkey(monkey)
  # ...
end
```

handle request in sinatra

``` ruby
post '/monkey' do
  MonkeyService.handle(request.body.read)
end
```

## test

```
cd test/
```

start a service in threaded mode

```
ruby ./app.rb -o 0.0.0.0 -e production
```

or

```
thin start -p 4567 --threaded -e production 
```

test parser

```
ruby ./get.rb
```

test writer

```
ruby ./set.rb
```

## todo

change range to elsif 

supports packet and envelope

rsa aes encryption

write in c

## authors

[takafan](http://hululuu.com)

## license

[Ruby License](http://www.ruby-lang.org/en/LICENSE.txt)
