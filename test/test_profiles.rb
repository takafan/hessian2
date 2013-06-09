# -*- encoding: utf-8 -*-
lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'connection_pool'
require 'benchmark'

# serv = Hessian2::HessianClient.new('http://192.168.3.161:8100/passport/hessian/userProfileService')
# prof = serv.getMultiUserBasicInfos([725].map{|uid| Hessian2::TypeWrapper.new('L', uid)})
# puts prof[725]['nickname']


# cserv = ConnectionPool.new(size: 5) do
#   Hessian2::Client.new('http://127.0.0.1:9292/monkey')
# end



# x = Benchmark.realtime do
  
#   10.times do 
    
#     # puts serv.wait1
#     res = cserv.with do |c|
#       c.wait1
#     end
#     puts res
#   end
  
# end

# puts x

c1 = Hessian2::Client.new("http://#{ARGV[1] || '127.0.0.1'}:4567/monkey")

puts c1.wait_taka(ARGV[0] || 'taka')
