class MonkeyService
  extend Hessian2::Handler

  def self.sleep(name = '')
    Kernel.sleep 1

    "wake #{name}"
  end

  def self.asleep(name = '')
    EM::Synchrony.sleep(1)

    "awake #{name}"
  end

end
