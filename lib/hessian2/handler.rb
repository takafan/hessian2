require 'hessian2'

module Hessian2
  module Handler

    def handle(data)
      val = Hessian2.parse_rpc(data)
      begin
        res = self.send(*val)
      rescue NoMethodError, ArgumentError => e
        Hessian2.write_fault(e)
      else
        Hessian2.reply(res)
      end
    end

  end
end
