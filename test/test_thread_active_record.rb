require 'active_record'
require 'thread/pool'
require 'yaml'

options = YAML.load_file(File.expand_path('../../spec/database.yml', __FILE__))
puts options.inspect

number_of = 10
concurrency = 4
connection_pool_size = 2
results = []

thread_pool = Thread.pool(concurrency)
db = ActiveRecord::Base.establish_connection(options.merge('pool' => connection_pool_size))

number_of.times do |i|
  thread_pool.process do
    puts i
    results << ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute('select sleep(1)')
    end
  end
end

puts "results.size #{results.size}"
thread_pool.shutdown

puts results.inspect
puts "results.size #{results.size}"

# time ruby test_thread_active_record.rb
