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

  if RUBY_VERSION < "1.9.3"
    spec.add_dependency "activesupport", "~> 3.0"
    spec.add_dependency "mime-types", "~> 1.25.0"
  else
    spec.add_dependency "activesupport", ">= 3.0.0"
  end
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec" 
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "json"
  spec.add_development_dependency "coveralls"

  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "faraday_middleware-multi_json"
  spec.add_dependency "oauth2"
  spec.add_dependency "hashie"
end
