lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'benchmark'

class User 
  attr_accessor :first_name, :last_name
end

SUser = Struct.new(:first_name, :last_name)

user = User.new
user.first_name = "Lloyd"
user.last_name = "Christmas"

hes1 = Hessian2.write(user)
puts 'hes1'
puts hes1.inspect
puts hes1.size

user_fromhes1 = Hessian2.parse(hes1)
puts user_fromhes1.first_name
puts user_fromhes1.last_name

hes2 = Hessian2.write(%w[ Lloyd Christmas ])
puts 'hes2'
puts hes2.inspect
puts hes2.size

user_fromhes2 = Hessian2.parse(hes2, SUser)
puts user_fromhes2.first_name
puts user_fromhes2.last_name

number_of = 10000

Benchmark.bmbm do |x|

  x.report "hes1" do
    number_of.times do
      Hessian2.parse(hes1)
    end
  end

  x.report "hes2" do
    number_of.times do
      Hessian2.parse(hes2, SUser)
    end
  end

end
