# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rbraspag/version"

Gem::Specification.new do |s|
  s.name        = "rbraspag"
  s.version     = Braspag::VERSION
  s.authors     = ["Celestino Gomes", "Renato Elias", "Luca Bastos", "Lenon Marcel", "Madson Cardoso"]
  s.email       = %w[tinorj@gmail.com renato.elias@gmail.com lucabastos@gmail.com lenon.marcel@gmail.com madsonmac@gmail.com]
  s.homepage    = "http://github.com/concretesolutions/rbraspag"
  s.summary     = "rbraspag gem to use Braspag gateway"
  s.description = "rbraspag gem to use Braspag gateway"

  s.rubyforge_project = "rbraspag"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "cs-httpi", "0.9.5.2"
  s.add_dependency "json"
  s.add_dependency "nokogiri"

  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "ruby-debug19"
end
