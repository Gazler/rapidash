# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rapidash/version"

Gem::Specification.new do |spec|
  spec.name          = "rapidash"
  spec.version       = Rapidash::VERSION
  spec.authors       = ["Gary 'Gazler' Rennie"]
  spec.email         = ["gazler@gmail.com"]
  spec.description   = %q{Evolve your API}
  spec.summary       = %q{An opinionated core for creating clients for RESTful APIs quickly}
  spec.homepage      = "http://github.com/Gazler/rapidash"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.0.0"
  spec.add_development_dependency "bundler", "~> 1.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "json"
  spec.add_development_dependency "coveralls"

  spec.add_dependency "faraday", "~> 0.8"
  spec.add_dependency "faraday_middleware", "~> 0.9"
  spec.add_dependency "faraday_middleware-multi_json", "~> 0.0"
  spec.add_dependency "oauth2", ">= 0.6", "< 2.0"
  spec.add_dependency "hashie", ">1.2", "< 4.0"
end
