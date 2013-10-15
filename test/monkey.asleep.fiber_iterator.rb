lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'em-synchrony'
require 'em-synchrony/fiber_iterator'

number_of = 10
concurrency = 2
results = []

client = Hessian2::Client.new('http://127.0.0.1:8080/', fiber_aware: true, async: true)

EM.synchrony do
  EM::Synchrony::FiberIterator.new(0...number_of, concurrency).each do |i|
    puts i
    results << client.asleep
  end

  puts "results.size #{results.size}"
  EM.stop
end

puts results.inspect
puts "results.size #{results.size}"
