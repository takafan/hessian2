module Hessian2
  class StructWrapper
    attr_accessor :klass, :objects
    def initialize(klass, *objects)
    	raise ArgumentError, "wrong number of arguments (#{ARGV.size} for 2+)" if objects.empty?
      @klass, @objects = klass, objects
    end
  end
end
