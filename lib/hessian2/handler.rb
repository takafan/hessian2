require 'hessian2/parser'
require 'hessian2/writer'

module Hessian2
  module Handler
    include Parser
    include Writer

    def handle(call)
      reply(self.send(*parse(call)))
    end

  end
end
