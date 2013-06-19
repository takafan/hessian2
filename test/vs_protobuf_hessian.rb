lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'benchmark'
require 'protobuf'
require 'protobuf/message'

module Foo
  class User < ::Protobuf::Message
    required ::Protobuf::Field::StringField, :first_name, 1
    required ::Protobuf::Field::StringField, :last_name, 2
  end
end

user = Foo::User.new
user.first_name = "Lloyd"
user.last_name = "Christmas"

bytes = user.serialize_to_string
puts 'protobuf'
puts bytes.inspect
puts bytes.size

user_from_buf = user.parse_from_string(bytes)
puts user_from_buf.first_name
puts user_from_buf.last_name

User = Struct.new(:first_name, :last_name)

hes = Hessian2.write(%w[ Lloyd Christmas ])
puts 'hessian2'
puts hes.inspect
puts hes.size

user_from_hes = Hessian2.parse(hes, User)
puts user_from_hes.first_name
puts user_from_hes.last_name

number_of = 10000

Benchmark.bmbm do |x|

  x.report "protobuf" do
    number_of.times do
      user.parse_from_string(bytes)
    end
  end

  x.report "hessian2" do
    number_of.times do
      Hessian2.parse(hes, User)
    end
  end

end
