lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

@number_of = 10
@concurrency = 2
@results = []
