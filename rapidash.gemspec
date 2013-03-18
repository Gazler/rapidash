# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rapidash/version'

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

  spec.add_development_dependency "bundler", "~> 1.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.8"

  spec.add_dependency 'json'
  spec.add_dependency 'faraday', '~> 0.8'
  spec.add_dependency "oauth2", "~>0.6"
  spec.add_dependency "hashie", "~>1.2"
  spec.add_dependency "activesupport"

end
