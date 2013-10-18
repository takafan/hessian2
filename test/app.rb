require File.expand_path('../monkey_service',  __FILE__)

set :logging, false

get '/' do
  status 405
  'post me'
end

post '/' do
  puts '/'
  MonkeyService.handle(request.body.read)
end

route :get, :post, '/sleep' do
  sleep 1

  'wake'
end

route :get, :post, '/asleep' do
  EM::Synchrony.sleep(1)

  'awake'
end
