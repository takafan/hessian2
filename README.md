# hessian2

json encode fast, hessian write small.

hessian2 implements hessian 2.0 protocol. check {web services protocol}[http://hessian.caucho.com/doc/hessian-ws.html] and {serialization protocol}[http://hessian.caucho.com/doc/hessian-serialization.html].

install:

```
gem install hessian2
```

## comparing

sending 10_000 monkeys:

yajl-ruby: encode/parse fast, json is readable and popular.

msgpack: pack/unpack most efficiency.

marshal: sending object, dump fast, 1/3 smaller than yajl, load fastest, but it's ruby only.

hessian2: sending object, referencable, serialize field names once then following objects only values, therefore 1/8 smaller than yajl —— saving transfer. write/parse a little slow because it's not c yet.

## serializing

``` ruby
require 'hessian2'
data = Hessian2.write(obj)
```

## deserializing 

``` ruby
require 'hessian2'
obj = Hessian2.parse(data)
```

## client

``` ruby
url = 'http://127.0.0.1:9292/monkey'
client = Hessian2::Client.new(url)
```

### call remote function, send a monkey

``` ruby
monkey = Monkey.new(name: '阿门', age: 7)
client.send_monkey(monkey)
```

## class wrapper

### wrap a hash as a monkey

``` ruby
hash = {name: '阿门', age: 7}
monkey = Hessian2::ClassWrapper.new('Monkey', hash)
```

### wrap a batch of monkeys

``` ruby
arr = [{name: '阿门', age: 7}, {name: '大鸡', age: 6}]
monkeys = Hessian2::ClassWrapper.new('[Monkey', arr)
```

## type wrapper

### wrap a string as long

``` ruby
str = '-0x8_000_000_000_000_000'
long = Hessian2::TypeWrapper.new('L', str)
```

### wrap a file as binary

``` ruby
binstr = IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__))
file = Hessian2::TypeWrapper.new('B', binstr)
```

### wrap a batch of files

``` ruby
arr = [binstr1, binstr2]
files = Hessian2::TypeWrapper.new('[B', arr))
```

## service

### extend hessian handler

``` ruby
class MonkeyService
  extend Hessian2::Handler

  def self.send_monkey(monkey)
  # ...
end
```

### handle request in sinatra

``` ruby
post '/monkey' do
  MonkeyService.handle(request.body.read)
end
```

## test

```
cd test/
```

### start a service

```
rackup -E production
```

### test parser

```
ruby ./get.rb
```

### test writer

```
ruby ./set.rb
```

## todo

classwrapper typewrapper

supports packet+ and envelope+

rsa aes encryption

write in c

## authors

[takafan](http://hululuu.com)

## license

MIT
