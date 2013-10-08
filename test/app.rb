lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'sinatra'
require File.expand_path('../monkey_service',  __FILE__)

set :logging, false

get '/' do
  status 405
  'post me'
end

post '/' do
  MonkeyService.handle(request.body.read)
end
