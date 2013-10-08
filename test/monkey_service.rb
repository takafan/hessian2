lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

class MonkeyService
  extend Hessian2::Handler

  def self.say(name)
    "hello #{name}"
  end

end
