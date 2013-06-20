lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'benchmark'
require 'redis'
require 'redis/connection/hiredis' 
require 'memcached'
require 'mysql2'
require 'active_record'
require 'yajl'
require 'msgpack'
require 'protobuf'

class Track < ActiveRecord::Base
  attr_accessible :id, :title, :intro, :created_at
end

TrackStruct = Struct.new(:id, :title, :intro, :created_at)

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module Proto

  ##
  # Message Classes
  #
  class Track < ::Protobuf::Message; end
  
  ##
  # Message Fields
  #
  class Track
    required ::Protobuf::Field::Int32Field, :id, 1
    optional ::Protobuf::Field::StringField, :title, 2
    optional ::Protobuf::Field::StringField, :intro, 3
    required ::Protobuf::Field::Int32Field, :created_at, 4
  end
  
  
end

options = YAML.load_file(File.expand_path('../options.yml', __FILE__))
redis_opts = options['redis']
redis = Redis.new(driver: :hiredis, host: redis_opts['host'], port: redis_opts['port'], 
  password: redis_opts['password'], db: redis_opts['db'] || 0)
cache = Memcached.new(options['cache_connstr'])
ActiveRecord::Base.establish_connection(options['mysql'])
ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.time_zone_aware_attributes = true

if options['seed']
  begin
    table_name = Track.table_name
    ActiveRecord::Base.connection.execute("truncate table #{table_name}")
    now = Time.new
    1.upto(1000).each do |i|
      Track.create(id: i, title: "标题#{i}", intro: "intro#{i}", created_at: now)
    end
  rescue ActiveRecord::StatementInvalid => e
    conn = ActiveRecord::Base.connection
    conn.execute("drop table if exists #{table_name}")
    conn.execute("create table #{table_name}(id integer(11) not null auto_increment, title varchar(255), intro text, created_at datetime, primary key(id)) charset=utf8")
    retry
  end
end

id = 59
track = Track.find(id)
attrs = track.attributes
attrs2 = {}
attrs.each do |k, v|
  attrs2[k] = v.is_a?(Time) ? v.to_i : v
end

values = []
values2 = []
TrackStruct.members.each do |m|
  values << attrs[m.to_s]
  values2 << attrs2[m.to_s]
end

puts track.inspect
puts "attrs: #{attrs.inspect}"
puts "attrs2: #{attrs2.inspect}"
puts "values: #{values.inspect}"
puts "values2: #{values2.inspect}"
puts

# hessian2

hes = Hessian2.write(Hessian2::StructWrapper.new(TrackStruct, track))
heskey = "track#{track.id}.hes"
redis.set(heskey, hes)
cache.set(heskey, hes)

puts heskey
puts hes.inspect
puts hes.size
puts Hessian2.parse(hes, TrackStruct).inspect
puts

# marshal

mar = Marshal.dump(values)
markey = "track#{track.id}.mar"
redis.set(markey, mar)
cache.set(markey, mar)

puts markey
puts mar.inspect
puts mar.size
puts TrackStruct.new(*Marshal.load(mar)).inspect
puts

# yajl

json = Yajl::Encoder.encode(values2)
jsonkey = "track#{track.id}.json"
redis.set(jsonkey, json)
cache.set(jsonkey, json)

puts jsonkey
puts json.inspect
puts json.size
puts TrackStruct.new(*Yajl::Parser.parse(json)).inspect
puts

# msgpack

msg = MessagePack.dump(values2)
msgkey = "track#{track.id}.msg"
redis.set(msgkey, msg)
cache.set(msgkey, msg)

puts msgkey
puts msg.inspect
puts msg.size
puts TrackStruct.new(*MessagePack.unpack(msg)).inspect
puts

# protobuf

pro = Proto::Track.new(attrs2).serialize_to_string
prokey = "track#{track.id}.pro"
redis.set(prokey, pro)
cache.set(prokey, pro)

puts prokey
puts pro.inspect
puts pro.size
puts Proto::Track.new.parse_from_string(pro).inspect
puts

# benchmark

raise "#{track.title} not cached" unless [
  Hessian2.parse(redis.get(heskey), TrackStruct).title, 
  Hessian2.parse(cache.get(heskey), TrackStruct).title,
  track.title ].uniq.size == 1

raise 'created_at not match' unless [
  Hessian2.parse(hes, TrackStruct).created_at, 
  TrackStruct.new(*Marshal.load(mar)).created_at,
  Time.at(TrackStruct.new(*Yajl::Parser.parse(json)).created_at),
  Time.at(TrackStruct.new(*MessagePack.unpack(msg)).created_at),
  Time.at(Proto::Track.new.parse_from_string(pro).created_at) ].uniq.size == 1

number_of = ARGV.first ? ARGV.first.to_i : 5959

Benchmark.bmbm do |x|

  x.report "redis hes" do
    number_of.times do
      Hessian2.parse(redis.get(heskey), TrackStruct)
    end
  end

  x.report "memcached hes" do
    number_of.times do
      Hessian2.parse(cache.get(heskey), TrackStruct)
    end
  end
  
  x.report "mysql2" do
    number_of.times do
      Track.find(id)
    end
  end

  x.report "hes" do
    number_of.times do
      Hessian2.parse(hes, TrackStruct).created_at
    end
  end

  x.report "mar" do
    number_of.times do
      TrackStruct.new(*Marshal.load(mar)).created_at
    end
  end

  x.report "json" do
    number_of.times do
      Time.at(TrackStruct.new(*Yajl::Parser.parse(json)).created_at)
    end
  end

  x.report "msg" do
    number_of.times do
      Time.at(TrackStruct.new(*MessagePack.unpack(msg)).created_at)
    end
  end

  x.report "pro" do
    number_of.times do
      Time.at(Proto::Track.new.parse_from_string(pro).created_at)
    end
  end

end
