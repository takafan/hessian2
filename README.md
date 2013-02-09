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
client.send_monkey(monkey)
```

## type wrapper

### send a file as binary

``` ruby
binstr = IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__))
client.send_file(Hessian2::TypeWrapper.new('B', binstr))
```

### send a string as long

``` ruby
client.send_long(Hessian2::TypeWrapper.new('L', '-0x8_000_000_000_000_000'))
```

## class wrapper

### send a hash as a monkey defined on remote

``` ruby
hash = {name: '阿门', age: 7}
client.send_monkey(Hessian2::ClassWrapper.new('Monkey', hash))
```

### send a array as a batch of monkeys

``` ruby
arr = [{name: '阿门', age: 7}, {name: '大鸡', age: 6}]
client.send_monkeys( arr.map{|hash| Hessian2::ClassWrapper.new('Monkey', hash)} )
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

parse objects by type TypeWrapper.new('[Monkey', [{name: '阿门', age: 7}])

supports packet+ and envelope+

rsa aes encryption

write in c

## authors

[takafan](http://hululuu.com)

## license

MIT
