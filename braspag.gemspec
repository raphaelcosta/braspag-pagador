# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{braspag}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gonow"]
  s.date = %q{2009-09-30}
  s.email = %q{labs@gonow.com.br}
  s.files = ["lib/braspag.rb", "lib/braspag/transaction.rb", "lib/braspag/cryptography.rb", "lib/braspag/layout.rb", "LICENSE", "VERSION", "Rakefile", "README.rdoc"]
  s.homepage = %q{http://www.gonow.com.br}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Access the Braspag webservices using Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubigen>, [">= 1.3.4"])
    else
      s.add_dependency(%q<rubigen>, [">= 1.3.4"])
    end
  else
    s.add_dependency(%q<rubigen>, [">= 1.3.4"])
  end
end
