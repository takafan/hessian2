module Hessian2
  class StructWrapper
    attr_accessor :klass, :object
    def initialize(klass, object)
      @klass = klass.is_a?(Array) ? klass.first : klass
      @object = object
    end
  end
end
