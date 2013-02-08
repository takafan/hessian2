require 'hessian2'

module Hessian2
  module Handler

    def handle(data)
      Hessian2.reply(self.send(*Hessian2.parse_rpc(data)))
    end

  end
end
