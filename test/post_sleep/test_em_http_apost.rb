require 'em-synchrony'
require 'em-synchrony/em-http'
require 'em-synchrony/fiber_iterator'
require 'net/http'

number_of = 10
concurrency = 2
results = []

EM.synchrony do
  EM::Synchrony::FiberIterator.new(0...number_of, concurrency).each do |i|
    puts i
    apost = EM::HttpRequest.new("http://127.0.0.1:8080/sleep").apost
    apost.callback do |r| 
      puts 'callback' 
      results << r.response
      EM.stop if results.size >= number_of
    end

    apost.errback do |r|
      puts 'errback'
      puts r.error
      EM.stop
    end
  end

  puts "results.size #{results.size}"
end

puts results.inspect
puts "results.size #{results.size}"
