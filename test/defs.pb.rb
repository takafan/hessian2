##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module Proto

  ##
  # Message Classes
  #
  class Monkey < ::Protobuf::Message; end
  
  ##
  # Message Fields
  #
  class Monkey
    required ::Protobuf::Field::Int32Field, :born_at, 1
    optional ::Protobuf::Field::Int32Field, :id, 2
    optional ::Protobuf::Field::StringField, :name, 3
    required ::Protobuf::Field::FloatField, :price, 4
  end
  
  
end

