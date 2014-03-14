module Hessian2
  class ClassWrapper
    attr_reader :klass, :fields, :values, :is_multi

    def initialize(klass, object)
    	raise 'klass should not be nil' unless klass
      
      if klass.include?('[')
      	is_multi = true
	      klass.delete!('[]')

      	sample = object.select{|x| x}.first
        unless sample # all nil
	      	values = [ nil ] * object.size
	      else
	      	fields = if sample.is_a?(Hash)
		      	sample.keys.map{|k| k.to_sym }
          elsif sample.instance_variable_get(:@values).is_a?(Hash)
            sample.values.keys.map{|k| k }
		      elsif sample.instance_variable_get(:@attributes).is_a?(Hash)
		      	sample.attributes.keys.map{|k| k.to_sym }
          elsif sample.is_a?(ClassWrapper)
            sample.fields
          elsif sample.is_a?(TypeWrapper)
            sample.object.keys.map{|k| k.to_sym }
		      else
		      	sample.instance_variables.map{|k| k[1..-1].to_sym }
		      end

		      raise "fields should not be empty: #{object.inspect}" if fields.empty?

		      values = object.map do |obj|
		      	if obj.nil?
		      		nil
		      	elsif obj.is_a?(Hash)
			        fields.map{|f| obj[f] || obj[f.to_s] }
            elsif obj.instance_variable_get(:@values).is_a?(Hash)
              fields.map{|f| obj.values[f] }
			      elsif obj.instance_variable_get(:@attributes).is_a?(Hash)
			        fields.map{|f| obj.attributes[f.to_s] }
            elsif obj.is_a?(ClassWrapper)
              obj.values
            elsif obj.is_a?(TypeWrapper)
              fields.map{|f| obj.object[f] || obj.object[f.to_s] }
			      else
			        fields.map{|f| obj.instance_variable_get(f.to_s.prepend('@')) }
			      end
		      end
	      end
	    else
	    	is_multi = false

	    	if object
	    		fields, values = [], []
		    	if object.is_a?(Hash)
		        object.each do |k, v|
		        	fields << k.to_sym
		        	values << v
		        end
          elsif object.instance_variable_get(:@values).is_a?(Hash)
            object.values.each do |k, v|
              fields << k
              values << v
            end
		      elsif object.instance_variable_get(:@attributes).is_a?(Hash)
		        object.attributes.each do |k, v|
		        	fields << k.to_sym
		        	values << v
		        end
          elsif object.is_a?(ClassWrapper)
            fields, values = object.fields, object.values
          elsif object.is_a?(TypeWrapper)
            object.object.each do |k, v|
              fields << k.to_sym
              values << v
            end
		      else
		        object.instance_variables.each do |var|
		        	k = var[1..-1]
		        	fields << k.to_sym
		        	values << object.instance_variable_get(k.prepend('@'))
		        end
		      end

		      raise "fields should not be empty: #{object.inspect}" if fields.empty?
		    end
	    end

      @klass, @fields, @values, @is_multi = klass, fields, values, is_multi 
    end


    def is_multi?
    	@is_multi
    end

  end
end
