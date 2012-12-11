lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'sinatra'
require 'hessian2'

class Person
  include Hessian2::Handler
  attr_accessor :age

  def younger(opts={})
    opts.each { |k, v| instance_variable_set("@#{k}", v) }
    self.age -= 1 if self.age
    self
  end

end

get '/' do
  status 405
  'post me'
end

post '/person' do
  person = Person.new
  begin
    status 200
    puts request.inspect
    person.handle(request.body.string)
  rescue Exception => e
    status 500
    person.write_fault(e)
  end
end
