module Hessian2
  class ClassWrapper
    attr_reader :klass, :fields, :values, :is_multi

    def initialize(klass, object)
    	raise "klass should not be nil: #{klass}" unless klass

      fields = []
      
      if klass.include?('[')
      	sample = object.select{|x| x}.first
      	raise 'no object' unless sample

      	is_multi = true
      	klass.delete!('[]')

	      if sample.is_a?(Hash)
	      	fields = sample.keys.map{|k| k.to_sym }
	      elsif sample.instance_variable_get(:@attributes).is_a?(Hash)
	      	fields = sample.attributes.keys.map{|k| k.to_sym }
	      else
	      	fields = sample.instance_variables.map{|k| k[1..-1].to_sym }
	      end

	      raise "fields should not be empty: #{object.inspect}" if fields.empty?

	      values = []
	      object.each do |obj|
	      	vals = []
	      	if obj.is_a?(Hash)
		        fields.each{|f| vals << obj[f] || obj[f.to_s] }
		      elsif obj.instance_variable_get(:@attributes).is_a?(Hash)
		        fields.each{|f| vals << obj.attributes[f.to_s] }
		      else
		        fields.each{|f| vals << obj.instance_variable_get(f.to_s.prepend('@')) }
		      end
		      values << vals
	      end
	    else
	    	raise 'no object' unless object

	    	is_multi = false

	    	fields = []
	    	if object.is_a?(Hash)
	    		values = []
	        object.each do |k, v|
	        	fields << k.to_sym
	        	values << v
	        end
	      elsif object.instance_variable_get(:@attributes).is_a?(Hash)
	      	values = []
	        object.attributes.each do |k, v|
	        	fields << k.to_sym
	        	values << v
	        end
	      else
	      	values = []
	        object.instance_variables.each do |var|
	        	k = var[1..-1]
	        	fields << k.to_sym
	        	values << object.instance_variable_get(k.prepend('@'))
	        end
	      end

	      raise "fields should not be empty: #{object.inspect}" if fields.empty?
	    end

      @klass, @fields, @values, @is_multi = klass, fields, values, is_multi 
    end

  end
end
