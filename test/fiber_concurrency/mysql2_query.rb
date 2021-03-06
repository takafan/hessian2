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
    results << db.query('select sleep(1)').first
  end

  puts "results.size #{results.size}"
  EM.stop
end

puts results.inspect
puts "results.size #{results.size}"
