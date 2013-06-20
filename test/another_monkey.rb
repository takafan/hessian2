class AnotherMonkey
  attr_accessor :born_at, :id, :name, :price

  def initialize(attrs = {})
    attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
  end
end
