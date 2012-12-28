module Hessian2
  class ClassWrapper
    attr_accessor :hessian_class, :object
    def initialize(hessian_class, object)
      @hessian_class, @object = hessian_class, object
    end
  end
end
