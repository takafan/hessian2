require 'hessian2/parser'
require 'hessian2/writer'

module Hessian2
  module Handler

    def self.handle(data)
      Hessian2::Writer.reply(self.send(*Hessian2::Parser.parse(data)))
    end

  end
end
