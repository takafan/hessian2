require 'net/http'
require 'thread/pool'

number_of = 10
concurrency = 2
results = []

thread_pool = Thread.pool(concurrency)

number_of.times do |i|
  thread_pool.process do
    puts i
    Net::HTTP.new('127.0.0.1', 8080).start do |http|
      results << http.request(Net::HTTP::Post.new('/sleep')).body
    end
  end
end

puts "results.size #{results.size}"
thread_pool.shutdown

puts results.inspect
puts "results.size #{results.size}"
