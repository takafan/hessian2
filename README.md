# hessian2

json encode fast, hessian write small.

hessian2 implements hessian 2.0 protocol. check {web services protocol}[http://hessian.caucho.com/doc/hessian-ws.html] and {serialization protocol}[http://hessian.caucho.com/doc/hessian-serialization.html].

## comparing

data size after serializing 10_000 monkeys/hashes, and serializing|deserializing spent on my pc:

yajl-ruby: 9.33MB (0.68s|0.81s)

msgpack: 7.65MB (0.14s|0.32s)

marshal: 2.68MB (0.21s|0.14s)

hessian2: 1.11MB (2.44s|4.61s)

## choosing

readable: yajl-ruby

serializing/deserializing efficiently: msgpack

sending objects, but ruby only: marshal

sending objects, saving transfer: hessian2

## install

```
gem install hessian2
```

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

### call remote method, send a monkey

``` ruby
monkey = Monkey.new(name: '阿门', age: 7)
client.send_monkey(monkey)
```

## class wrapper

### wrap a hash to a monkey

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

### wrap a string to long

``` ruby
str = '-0x8_000_000_000_000_000'
long = Hessian2::TypeWrapper.new('L', str)
```

### wrap a file to binary

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

supports packet+ and envelope+

rsa aes encryption

write in c

## authors

[takafan](http://hululuu.com)

## license

MIT
