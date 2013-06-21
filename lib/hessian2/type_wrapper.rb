module Hessian2
  class TypeWrapper
    attr_accessor :hessian_type, :object
    def initialize(hessian_type, object)
      @hessian_type = hessian_type.is_a?(Array) ? ('[' + unify_type(hessian_type.first)) : unify_type(hessian_type)
      @object = object
    end

    private

    def unify_type(hessian_type)
      case hessian_type
      when 'L', 'l', 'Long', 'long', :long
        'L'
      when 'I', 'i', 'Integer', 'int', :int
        'I'
      when 'B', 'b', 'Binary', 'bin', :bin
        'B'
      else
        hessian_type
      end
    end
  end
end
