lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'em-synchrony'

client = Hessian2::Client.new('http://127.0.0.1:8080/', fiber_aware: true, async: true)

EM.synchrony do
  
  puts client.asleep ARGV.first

  # loop do
  #   if client.async_result.size > 0
  #     EM.stop
  #     break 
  #   end

  #   sleep 1
  # end

  # loop do
  #   puts client.async_result.size > 0

  #   sleep 1
  # end

  
end
puts "got #{client.async_result}"