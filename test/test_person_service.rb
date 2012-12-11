lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

person = Hessian2::Client.new('http://127.0.0.1:9999/person')
puts person.younger(name: 'kimokbin', age: 16)
