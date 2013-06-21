lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)

require 'benchmark'
require 'hessian2'
require 'memcached'
require 'msgpack'
require 'protobuf'
require 'redis'
require 'redis/connection/hiredis' 
require 'yajl'
require File.expand_path('../defs.pb',  __FILE__)
require File.expand_path('../establish_connection',  __FILE__)
require File.expand_path('../monkey',  __FILE__)

options = YAML.load_file(File.expand_path('../options.yml', __FILE__))
redis_opts = options['redis']
redis = Redis.new(driver: :hiredis, host: redis_opts['host'], port: redis_opts['port'], 
  password: redis_opts['password'], db: redis_opts['db'] || 0)
cache = Memcached.new(options['cache_connstr'])

id = 59
monkey = Monkey.find(id)
attrs = monkey.attributes
attrs2 = {}
attrs.each do |k, v|
  attrs2[k] = case v 
  when Time
    v.to_i
  when BigDecimal
    v.to_f
  else
    v
  end
end

values = []
values2 = []
MonkeyStruct.members.each do |m|
  values << attrs[m.to_s]
  values2 << attrs2[m.to_s]
end

puts monkey.inspect
puts "attrs: #{attrs.inspect}"
puts "attrs2: #{attrs2.inspect}"
puts "values: #{values.inspect}"
puts "values2: #{values2.inspect}"
puts

# hessian2

hes = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, monkey))
heskey = "monkey#{monkey.id}.hes"
redis.set(heskey, hes)
cache.set(heskey, hes)

puts heskey
puts hes.inspect
puts hes.size
puts Hessian2.parse(hes, MonkeyStruct).inspect
puts

# marshal

mar = Marshal.dump(values)
markey = "monkey#{monkey.id}.mar"
redis.set(markey, mar)
cache.set(markey, mar)

puts markey
puts mar.inspect
puts mar.size
puts MonkeyStruct.new(*Marshal.load(mar)).inspect
puts

# yajl

json = Yajl::Encoder.encode(values2)
jsonkey = "monkey#{monkey.id}.json"
redis.set(jsonkey, json)
cache.set(jsonkey, json)

puts jsonkey
puts json.inspect
puts json.size
puts MonkeyStruct.new(*Yajl::Parser.parse(json)).inspect
puts

# msgpack

msg = MessagePack.dump(values2)
msgkey = "monkey#{monkey.id}.msg"
redis.set(msgkey, msg)
cache.set(msgkey, msg)

puts msgkey
puts msg.inspect
puts msg.size
puts MonkeyStruct.new(*MessagePack.unpack(msg)).inspect
puts

# protobuf

pro = Proto::Monkey.new(attrs2).serialize_to_string
prokey = "monkey#{monkey.id}.pro"
redis.set(prokey, pro)
cache.set(prokey, pro)

puts prokey
puts pro.inspect
puts pro.size
puts Proto::Monkey.new.parse_from_string(pro).inspect
puts

# benchmark

raise "#{monkey.name} not cached" unless [
  Hessian2.parse(redis.get(heskey), MonkeyStruct).name, 
  Hessian2.parse(cache.get(heskey), MonkeyStruct).name,
  monkey.name ].uniq.size == 1

raise 'born_at not match' unless [
  Hessian2.parse(hes, MonkeyStruct).born_at, 
  MonkeyStruct.new(*Marshal.load(mar)).born_at,
  Time.at(MonkeyStruct.new(*Yajl::Parser.parse(json)).born_at),
  Time.at(MonkeyStruct.new(*MessagePack.unpack(msg)).born_at),
  Time.at(Proto::Monkey.new.parse_from_string(pro).born_at) ].uniq.size == 1

number_of = ARGV.first ? ARGV.first.to_i : 5959

Benchmark.bmbm do |x|

  x.report "redis hes" do
    number_of.times do
      Hessian2.parse(redis.get(heskey), MonkeyStruct)
    end
  end

  x.report "memcached hes" do
    number_of.times do
      Hessian2.parse(cache.get(heskey), MonkeyStruct)
    end
  end
  
  x.report "mysql2" do
    number_of.times do
      Monkey.find(id)
    end
  end

  x.report "hes" do
    number_of.times do
      Hessian2.parse(hes, MonkeyStruct).born_at
    end
  end

  x.report "mar" do
    number_of.times do
      MonkeyStruct.new(*Marshal.load(mar)).born_at
    end
  end

  x.report "json" do
    number_of.times do
      Time.at(MonkeyStruct.new(*Yajl::Parser.parse(json)).born_at)
    end
  end

  x.report "msg" do
    number_of.times do
      Time.at(MonkeyStruct.new(*MessagePack.unpack(msg)).born_at)
    end
  end

  x.report "pro" do
    number_of.times do
      Time.at(Proto::Monkey.new.parse_from_string(pro).born_at)
    end
  end

end
