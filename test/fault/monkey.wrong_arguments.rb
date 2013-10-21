require File.expand_path('../../prepare',  __FILE__)

client = Hessian2::Client.new('http://127.0.0.1:8080/')

puts client.sleep('wrong', 'arguments')
