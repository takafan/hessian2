require File.expand_path('../../monkey_service',  __FILE__)

set :logging, false

get '/' do
  status 405
  'post me'
end

post '/' do
  MonkeyService.handle(request.body.read)
end

route :get, :post, '/sleep' do
  puts 'sleep 1'
  sleep 1

  'wake'
end

route :get, :post, '/asleep' do
  puts 'asleep 1'
  EM::Synchrony.sleep(1)

  'wake'
end
