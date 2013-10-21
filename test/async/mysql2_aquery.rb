require 'em-synchrony'
require 'em-synchrony/mysql2'
require 'em-synchrony/fiber_iterator'
require 'yaml'

options = YAML.load_file(File.expand_path('../../../spec/database.yml', __FILE__))
puts options.inspect

number_of = 10
concurrency = 2
connection_pool_size = 4
results = []

db = EM::Synchrony::ConnectionPool.new(size: connection_pool_size) do
  Mysql2::EM::Client.new(options)
end

EM.synchrony do
  EM::Synchrony::FiberIterator.new(0...number_of, concurrency).each do |i|
    puts i
    aquery = db.aquery('select sleep(1)')
    aquery.callback do |r| 
      puts 'callback' 
      results << r.first
      EM.stop if results.size >= number_of
    end
  end

  puts "results.size #{results.size}"
end

puts results.inspect
puts "results.size #{results.size}"

# time ruby test/async/mysql2_aquery.rb
# 并发数 >= db连接池的场合，aquery要等空闲连接出来，耗时和query一样
# 并发数 < db连接池的场合，aquery可以马上用空闲连接发起下一波查询，也就更早拿到callback，比query快
