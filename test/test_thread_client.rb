lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'thread/pool'

number_of = 10
concurrency = 2
results = []

thread_pool = Thread.pool(concurrency)
client = Hessian2::Client.new('http://127.0.0.1:8080/')

number_of.times do |i|
  thread_pool.process do
    puts i
    results << client.say
  end
end

puts "results.size #{results.size}"
thread_pool.shutdown

puts results.inspect
puts "results.size #{results.size}"
