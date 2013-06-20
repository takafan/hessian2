lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'benchmark'

class User 
  attr_accessor :first_name, :last_name
end

UserStruct = Struct.new(:first_name, :last_name)

user = User.new
user.first_name = "Lloyd"
user.last_name = "Christmas"

puts 'hes'
hes = Hessian2.write(user)
puts hes.inspect
puts hes.size

huser = Hessian2.parse(hes)
puts huser.first_name
puts huser.last_name

puts 'hes2'
hes2 = Hessian2.write(Hessian2::StructWrapper.new(UserStruct, user))
puts hes2.inspect
puts hes2.size

huser2 = Hessian2.parse(hes2, UserStruct)
puts huser2.first_name
puts huser2.last_name

number_of = 10000

Benchmark.bmbm do |x|

  x.report "hes" do
    number_of.times do
      Hessian2.parse(hes)
    end
  end

  x.report "hes2" do
    number_of.times do
      Hessian2.parse(hes2, UserStruct)
    end
  end

end
