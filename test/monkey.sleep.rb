lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

client = Hessian2::Client.new('http://localhost:8080/')
puts client.sleep ARGV.first
