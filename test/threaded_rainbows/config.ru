lib_path = File.expand_path('../../../lib', __FILE__)
$:.unshift(lib_path)

require 'hessian2'
require 'bundler'
Bundler.require

require ::File.expand_path('../../app',  __FILE__)
run Sinatra::Application
