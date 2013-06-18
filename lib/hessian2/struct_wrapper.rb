module Hessian2
  class StructWrapper
    attr_accessor :klass, :object
    def initialize(klass, object)
      @klass, @object = klass, object
    end
  end
end
