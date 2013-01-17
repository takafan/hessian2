require 'hessian2/parser'
require 'hessian2/writer'

module Hessian2
  module Handler
    include Writer

    def handle(call)
      reply(self.send(*Hessian2::Parser.parse(call)))
    end

  end
end
