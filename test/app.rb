lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'sinatra'
require ::File.expand_path('../person',  __FILE__)

get '/' do
  status 405
  'post me'
end

post '/person' do
  person = Person.new
  begin
    status 200
    person.handle(request.body.read)
  rescue Exception => e
    status 500
    puts e.message
    person.reply_fault(e)
  end
end
