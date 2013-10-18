require File.expand_path('../../prepare', __FILE__)
require 'thread/pool'

thread_pool = Thread.pool(@concurrency)
client = Hessian2::Client.new('http://127.0.0.1:8080/')

@number_of.times do |i|
  thread_pool.process do
    puts i
    begin
      @results << client.asleep
    rescue Hessian2::Fault => e
      puts "#{e.message}"
    end
  end
end

puts "results.size #{@results.size}"
thread_pool.shutdown

puts @results.inspect
puts "results.size #{@results.size}"
