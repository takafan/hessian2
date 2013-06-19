lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'benchmark'
require 'redis'
require 'redis/connection/hiredis' 
require 'memcached'
require 'mysql2'
require 'active_record'

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
class Track < ActiveRecord::Base; end
TrackStruct = Struct.new(:id, :title, :intro, :created_at)

if options['seed']
  begin
    table_name = Track.table_name
    ActiveRecord::Base.connection.execute("truncate table #{table_name}")
    now = Time.new
    1000.times do |i|
      track = Track.create(id: i, title: "标题#{i}", intro: "intro#{i}", created_at: now)
      key = "track#{track.id}.hes"
      bin = Hessian.write(Hessian::StructWrapper.new(TrackStruct, track))
      redis.set(key, bin)
      cache.set(key, bin)
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
key = "track#{track.id}.hes"

#
# 2. validate
#

[Hessian.parse(redis.get(key), TrackStruct), Hessian.parse(cache.get(key), TrackStruct)].each do |cached_track|
  raise "#{track.title} not cached" if cached_track.title != track.title
end

#
# 3. benchmark
#

Benchmark.bmbm do |x|

  x.report "redis" do
    number_of.times do
      Hessian.parse(redis.get(key), TrackStruct)
    end
  end

  x.report "memcached" do
    number_of.times do
      Hessian.parse(cache.get(key), TrackStruct)
    end
  end
  
  x.report "mysql" do
    number_of.times do
      Track.find(id)
    end
  end

end
