lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

client = Hessian2::Client.new('http://127.0.0.1:8080/')

puts client.asleep
