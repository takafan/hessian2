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
    client.asleep

    # http = client.asleep
    # http.callback do |r| 
    #   puts 'callback' 
    #   results << Hessian2.parse_rpc(r.response)
    #   EM.stop if results.size >= number_of
    # end

    # http.errback do |r|
    #   puts 'errback'
    #   puts r.error
    #   EM.stop
    # end
  end

  puts "results.size #{results.size}"
end

puts results.inspect
puts "results.size #{results.size}"
