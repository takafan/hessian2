module Hessian2
  class StructWrapper
    attr_reader :values
    
    def initialize(klass, object)
      raise "klass should not be nil: #{klass}" unless klass

      if klass.is_a?(Array)
    		is_multi = true
    		members = klass.first.members
    	elsif klass.is_a?(String)
    		if klass.include?('[')
    			is_multi = true
    			members = Kernel.const_get(klass.delete('[]')).members
    		else
    			is_multi = false
    			members = Kernel.const_get(klass).members
    		end
    	else
    		is_multi = false
    		members = klass.members
    	end

      if is_multi
        values = []
        object.each do |o|
          values << get_values(members, o)
        end
      else
        values = get_values(members, object)
      end
        
      @values = values
    end


    private

    def get_values(members, object)
      return nil unless object
      values = []
      if object.is_a?(Hash)
        members.each{|f| values << (object[f] || object[f.to_s]) }
      elsif object.instance_variable_get(:@values).is_a?(Hash)
        attrs = object.values
        members.each{|f| values << attrs[f] }
      elsif object.instance_variable_get(:@attributes).is_a?(Hash)
        attrs = object.attributes
        members.each{|f| values << attrs[f.to_s] }
      else
        members.each{|f| values << object.instance_variable_get(f.to_s.prepend('@')) }
      end
     
      values
    end

  end
end
