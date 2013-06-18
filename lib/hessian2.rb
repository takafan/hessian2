require 'hessian2/class_wrapper'
require 'hessian2/client'
require 'hessian2/fault'
require 'hessian2/handler'
require 'hessian2/hessian_client'
require 'hessian2/parser'
require 'hessian2/struct_wrapper'
require 'hessian2/type_wrapper'
require 'hessian2/version'
require 'hessian2/writer'

module Hessian2
  extend Parser, Writer
end
