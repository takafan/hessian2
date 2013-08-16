module Hessian2
  class StructWrapper
    attr_reader :values
    
    def initialize(klass, object)
      if klass.nil?
        is_struct = false
    	elsif klass.is_a?(Array)
    		is_struct = false
    		members = klass.first.members
    	elsif klass.is_a?(String)
    		if klass.include?('[')
    			is_struct = false
    			members = Kernel.const_get(klass.delete('[]')).members
    		else
    			is_struct = true
    			members = Kernel.const_get(klass).members
    		end
    	else
    		is_struct = true
    		members = klass.members
    	end

      if is_struct
        @values = get_values(members, object)
      else
        arr = []
        object.each do |o|
          arr << get_values(members, o)
        end

        @values = arr
      end
    end


    private

    def get_values(members, object)
      return nil unless object

      values = []
      if object.is_a?(Hash)
        members.each{|f| values << (object[f] || object[f.to_s]) }
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
