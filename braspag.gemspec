# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{braspag}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Concrete/Gonow"]
  s.date = %q{2011-06-17}
  s.email = %q{lucabastos@gmail.com;renato.elias@gmail.com}
  s.files = ["lib/braspag/recorrente.rb", "lib/braspag/service.rb", "lib/braspag/gateway.rb", "lib/braspag/connection.rb", "lib/braspag/cryptography.rb", "lib/braspag.rb", "Rakefile", "Gemfile", "README.textile", "Gemfile.lock"]
  s.homepage = %q{http://www.concretesolutions.com.br}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Access the Braspag webservices using Ruby}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpi>, [">= 0.9.4"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<httpi>, [">= 0.9.4"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<httpi>, [">= 0.9.4"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
