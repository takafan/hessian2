require 'bundler'
Bundler.require

use Rack::FiberPool

require ::File.expand_path('../app',  __FILE__)
run Sinatra::Application
