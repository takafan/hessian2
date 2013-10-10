lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

class MonkeyService
  extend Hessian2::Handler

  def self.say(name = '')
    sleep 3
    puts 'say'
    "hello #{name}"
  end

end
