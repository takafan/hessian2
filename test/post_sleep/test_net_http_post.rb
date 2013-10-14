require 'em-synchrony'
require 'em-synchrony/fiber_iterator'
require 'net/http'

number_of = 10
concurrency = 2
results = []

EM.synchrony do
  EM::Synchrony::FiberIterator.new(0...number_of, concurrency).each do |i|
    puts i
    Net::HTTP.new('127.0.0.1', 8080).start do |http|
      results << http.request(Net::HTTP::Post.new('/sleep')).body
    end
  end

  puts "results.size #{results.size}"
  EM.stop
end

puts results.inspect
puts "results.size #{results.size}"
