lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

client = Hessian2::Client.new('http://localhost:4567')

puts client.say ARGV.first

puts client.say2
