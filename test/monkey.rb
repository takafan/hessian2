require 'active_record'

class Monkey < ActiveRecord::Base; end

MonkeyStruct = Struct.new(:born_at, :id, :name, :price)
