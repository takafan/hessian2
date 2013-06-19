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
require 'protobuf'
require 'protobuf/message'

number_of = 5959

#
# 1. prepare
#

options = YAML.load_file(File.expand_path('../options.yml', __FILE__))
redis_opts = options['redis']
redis = Redis.new(driver: :hiredis, host: redis_opts['host'], port: redis_opts['port'], 
  password: redis_opts['password'], db: redis_opts['db'] || 0)
cache = Memcached.new(options['cache_connstr'])
ActiveRecord::Base.establish_connection(options['mysql'])
ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.time_zone_aware_attributes = true
class Track < ActiveRecord::Base
  attr_accessible :id, :title, :intro, :created_at
end
TrackStruct = Struct.new(:id, :title, :intro, :created_at)

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
attributes = track.attributes
values = []
TrackStruct.members.each do |m|
  values << attributes[m.to_s]
end

puts track.inspect
puts attributes
puts values.join(', ')

bin = Hessian2.write(Hessian2::StructWrapper.new(TrackStruct, attributes))
key = "track#{track.id}.hes"
redis.set(key, bin)
cache.set(key, bin)

htrack = Hessian2.parse(redis.get(key), TrackStruct)

puts key
puts bin.inspect
puts htrack.inspect


mar = Marshal.dump(values)
markey = "track#{track.id}.mar"
redis.set(markey, mar)
cache.set(markey, mar)

mtrack = TrackStruct.new(*Marshal.load(redis.get(markey)))

puts markey
puts mar.inspect
puts mtrack.inspect

json = Yajl::Encoder.encode(values)
jsonkey = "track#{track.id}.json"
redis.set(jsonkey, json)
cache.set(jsonkey, json)

jtrack = TrackStruct.new(*Yajl::Parser.parse(redis.get(jsonkey)))

puts jsonkey
puts json.inspect
puts jtrack.inspect

# module Proto
#   class User < ::Protobuf::Message
#     required ::Protobuf::Field::StringField, :id, 1
#     required ::Protobuf::Field::StringField, :last_name, 2
#     :id, :title, :intro, :created_at
#   end
# end

#
# 2. validate
#

[htrack, Hessian2.parse(cache.get(key), TrackStruct)].each do |cached_track|
  raise "#{track.title} not cached" if cached_track.title != track.title
end

#
# 3. benchmark
#

Benchmark.bmbm do |x|

  x.report "redis" do
    number_of.times do
      Hessian2.parse(redis.get(key), TrackStruct)
    end
  end

  x.report "memcached" do
    number_of.times do
      Hessian2.parse(cache.get(key), TrackStruct)
    end
  end
  
  x.report "mysql2" do
    number_of.times do
      Track.find(id)
    end
  end

  x.report "redis mar" do
    number_of.times do
      TrackStruct.new(*Marshal.load(redis.get(markey)))
    end
  end

  x.report "redis json" do
    number_of.times do
      TrackStruct.new(*Yajl::Parser.parse(redis.get(jsonkey)))
    end
  end

end
