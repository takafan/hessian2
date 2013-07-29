lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)

require 'hessian2'

require 'active_record'
require 'mysql2'

MonkeyStruct = Struct.new(:born_at, :id, :name, :price)

options = YAML.load_file(File.expand_path('../database.yml', __FILE__))
ActiveRecord::Base.establish_connection(options)
ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.time_zone_aware_attributes = true

class Monkey < ActiveRecord::Base; end

class AnotherMonkey
  attr_accessor :born_at, :id, :name, :price

  def initialize(attrs = {})
    attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
  end
end
