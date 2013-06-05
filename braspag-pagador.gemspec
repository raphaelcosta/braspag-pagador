# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "braspag-pagador/version"

Gem::Specification.new do |s|
  s.name        = "braspag-pagador"
  s.version     = BraspagPagador::VERSION
  s.authors     = ["CodeMiner42", "Renato Elias", "Cenize", "Raphael Costa"]
  s.email       = %w[contato@codeminer42.com renato.elias@gmail.com]
  s.homepage    = "http://github.com/raphaelcosta/braspag-pagador"
  s.summary     = "Braspag: brazilian gateway, agnostic, support all features in braspag"
  s.description = "Braspag: brazilian gateway, agnostic, support all features in braspag"

  s.rubyforge_project = "nowarning"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activemerchant', '>= 1.28.0'
  s.add_dependency 'active_attr', '>= 0.6'
  s.add_dependency 'httpi', '>= 0.9.6'
  s.add_dependency 'json', '>= 1.6.1'
  s.add_dependency 'nokogiri', '>= 1.4.7'
  s.add_dependency 'savon', '~> 2.2.0'

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "pry"
end
