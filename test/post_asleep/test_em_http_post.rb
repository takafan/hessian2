require 'em-synchrony'
require 'em-synchrony/em-http'
require 'em-synchrony/fiber_iterator'

number_of = 10
concurrency = 2
results = []

EM.synchrony do
  EM::Synchrony::FiberIterator.new(0...number_of, concurrency).each do |i|
    puts i
    results << EM::HttpRequest.new("http://127.0.0.1:8080/asleep").post.response
  end

  puts "results.size #{results.size}"
  EM.stop
end

puts results.inspect
puts "results.size #{results.size}"
