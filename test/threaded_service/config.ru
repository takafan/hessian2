require 'bundler'
Bundler.require

require ::File.expand_path('../app',  __FILE__)
run Sinatra::Application
