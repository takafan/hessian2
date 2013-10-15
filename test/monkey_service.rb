lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'em-synchrony'
require 'hessian2'

class MonkeyService
  extend Hessian2::Handler

  def self.sleep(name = '')
    puts 'handle sleep 1'

    Kernel.sleep 1

    "wake #{name}"
  end

  def self.asleep(name = '')
    puts 'asleep 1'
    EM::Synchrony.sleep(1)

    "awake #{name}"
  end

end
