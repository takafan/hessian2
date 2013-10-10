lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

url = 'http://localhost:4567'

# [ Hessian2::Client.new(url) ].each do |client|
#   puts client.class

#   t0 = Time.new
#   pool = Thread.pool(5)


#   1.times do
#     pool.process do
#       puts client.say ARGV.first
#     end
#   end


#   pool.shutdown
#   puts Time.new - t0
# end

# EventMachine.synchrony do
#   client = EventMachine::Synchrony::ConnectionPool.new(size: 5) do
#     Hessian2::Client.new(url)
#   end

#   multi = EventMachine::Synchrony::Multi.new
#   10.times do |i|
#     multi.add "a#{i}".to_sym, client.say(ARGV.first)
#   end
#   res = multi.perform

#   puts res

#   EventMachine.stop
# end

client = Hessian2::Client.new(url)

# t0 = Time.new
# pool = Thread.pool(5)

# 10.times do
#   pool.process do
#     puts client.say ARGV.first
#   end
# end






# pool.shutdown
# puts Time.new - t0

puts client.say ARGV.first

threads = []

10.times do
  threads << Thread.new {
    client.say ARGV.first
  }
end

threads.each{|t| t.join }
