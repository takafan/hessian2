lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'


f = 99.99

bin = Hessian2.write(f)
puts Hessian2.parse(bin)
t0 = Time.new
10000.times do
  Hessian2.parse(bin)
end
puts Time.new - t0