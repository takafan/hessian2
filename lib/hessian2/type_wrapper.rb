module Hessian
  class TypeWrapper
    attr_accessor :hessian_type, :object
    def initialize(hessian_type, object)
      @hessian_type, @object = hessian_type, object
    end
  end
end
