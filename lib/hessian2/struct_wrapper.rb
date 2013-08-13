module Hessian2
  class StructWrapper
    attr_accessor :members, :object
    attr_reader :is_multi
    def initialize(klass, object)
    	if klass.is_a?(Array)
    		@is_multi = true
    		@members = klass.first.members
    	elsif klass.is_a?(String)
    		if klass.include?('[')
    			@is_multi = true
    			@members = Kernel.const_get(klass.delete('[]')).members
    		else
    			@is_multi = false
    			@members = Kernel.const_get(klass).members
    		end
    	else
    		@is_multi = false
    		@members = klass.members
    	end

      @object = object
    end

    def is_multi?
    	self.is_multi
    end
  end
end
