module Hessian2
  class TypeWrapper
    attr_accessor :object
    attr_reader :hessian_type, :is_multi

    def initialize(type, object)
      if type.is_a?(Array)
        is_multi = true
        hessian_type = unify_type(type.first)
      elsif type.is_a?(String)
        if type.include?('[')
          is_multi = true
          hessian_type = unify_type(type.delete('[]'))
        else
          is_multi = false
          hessian_type = unify_type(type)
        end
      else
        is_multi = false
        hessian_type = unify_type(type)
      end

      @object, @hessian_type, @is_multi = object, hessian_type, is_multi
    end


    def is_multi?
      @is_multi
    end


    private

    def unify_type(type)
      case type
      when 'L', 'l', 'Long', 'long', :long
        'L'
      when 'I', 'i', 'Integer', 'int', :int
        'I'
      when 'B', 'b', 'Binary', 'bin', :bin
        'B'
      else
        type
      end
    end

    
  end
end
