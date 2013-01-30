lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'sinatra'
require ::File.expand_path('../monkey_service',  __FILE__)

get '/' do
  status 405
  'post me'
end

post '/monkey' do
  # begin
  #   status 200
  #   data = request.body.read
  #   puts data
  #   MonkeyService.handle(data)
  # rescue Exception => e
  #   status 500
  #   puts e.message
  #   MonkeyService.reply_fault(e)
  # end
  status 200
  data = request.body.read
  puts data
  MonkeyService.handle(data)
end
