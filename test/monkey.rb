class Monkey
  attr_accessor :age, :name

  def initialize(attrs = {})
    attrs.each { |key, val| send("#{key}=", val) if respond_to?("#{key}=") }
  end

end
