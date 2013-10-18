require File.expand_path('../../prepare', __FILE__)
require 'em-synchrony'
require 'em-synchrony/fiber_iterator'

client = Hessian2::Client.new('http://127.0.0.1:8080/')

EM.synchrony do
  EM::Synchrony::FiberIterator.new(0...@number_of, @concurrency).each do |i|
    puts i
    @results << client.sleep
  end

  puts "results.size #{@results.size}"
  EM.stop
end

puts @results.inspect
puts "results.size #{@results.size}"
