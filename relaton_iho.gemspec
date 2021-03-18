lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "relaton_iho/version"

Gem::Specification.new do |s|
  s.name          = "relaton-iho"
  s.version       = RelatonIho::VERSION
  s.authors       = ["Ribose Inc."]
  s.email         = ["open.source@ribose.com"]
  s.homepage      = "https://github.com/relaton/relaton-iho"
  s.licenses      = "BSD-2-Clause"
  s.summary       = "RelatonIho: retrieve IHO Standards for bibliographic "\
                    "using the BibliographicItem model"
  s.description   = "RelatonIho: retrieve IHO Standards for bibliographic "\
                    "using the BibliographicItem model"

  s.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  s.add_development_dependency "byebug"
  # s.add_development_dependency "debase"
  s.add_development_dependency "equivalent-xml", "~> 0.6"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  # s.add_development_dependency "ruby-debug-ide"
  s.add_development_dependency "ruby-jing"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"

  s.add_dependency "relaton-bib", "~> 1.7.0"
end
