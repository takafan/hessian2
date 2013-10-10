require 'hessian2'

module Hessian2
  module Handler

    def handle(data)
      # begin
        Hessian2.reply(self.send(*Hessian2.parse_rpc(data)))
      # rescue NoMethodError, ArgumentError, NameError, Fault => e
      #   Hessian2.write_fault(e)
      # end
    end

  end
end
