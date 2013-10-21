require File.expand_path('../../prepare', __FILE__)
require 'net/http'
require 'thread/pool'

thread_pool = Thread.pool(@concurrency)

@number_of.times do |i|
  thread_pool.process do
    puts i
    begin
      Net::HTTP.new('127.0.0.1', 8080).start do |http|
        @results << http.request(Net::HTTP::Post.new('/asleep')).body
      end
    rescue RuntimeError => e
      puts "#{e.message}"
    end
  end
end

puts "results.size #{@results.size}"
thread_pool.shutdown

puts @results.inspect
puts "results.size #{@results.size}"
