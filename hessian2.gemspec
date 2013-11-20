# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'hessian2/version'

Gem::Specification.new do |s|
  s.name        = 'hessian2'
  s.version     = Hessian2::VERSION
  s.authors     = ['takafan']
  s.email       = ['takafan@163.com']
  s.homepage    = 'http://github.com/takafan/hessian2'
  s.summary     = %q{Hessian2}
  s.description = %q{like json, additionally, 麻绳2 parse your object as a struct.}

  s.rubyforge_project = 'hessian2'
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'
  s.add_runtime_dependency 'activerecord'
  s.add_runtime_dependency 'bigdecimal'
end
