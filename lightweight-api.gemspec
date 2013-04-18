#!/usr/bin/env gem build
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = "lightweight-api"
  s.version       = "0.0.1"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Lighweight API Rack Middleware"
  s.require_paths = ["lib"]
  # s.files         = `git ls-files -- Gemfile README.md lib/ *.gemspec`.split("\n")
  # s.test_files    = `git ls-files -- .rspec Gemfile spec/`.split("\n")

  s.description   = "Lighweight API Rack Middleware"
  s.authors       = ["Musashi Team"]
  s.email         = "AgileTeamMusashi@abril.com.br"
  s.homepage      = "http://github.com/abril"

  s.add_runtime_dependency 'rack', '>= 1.3.0'

  s.add_development_dependency "rspec", ">= 2.6"
end
