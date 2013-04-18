#!/usr/bin/env gem build
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = "rack-lightweight-api"
  s.version       = "0.0.1"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Lighweight API Rack Middleware"
  s.require_paths = [ "lib" ]
  s.description   = "Lighweight API Rack Middleware"
  s.authors       = ["Musashi Team"]
  s.email         = "AgileTeamMusashi@abril.com.br"
  s.homepage      = "http://github.com/abril"

  s.add_runtime_dependency 'rack', '>= 1.3.0'

  s.add_development_dependency "rspec", ">= 2.6"
end
