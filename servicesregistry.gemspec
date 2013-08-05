# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'servicesregistry/version'

Gem::Specification.new do |spec|
  spec.name          = "servicesregistry"
  spec.version       = Servicesregistry::VERSION
  spec.authors       = ["Matthias Frick"]
  spec.email         = ["matthias@frick-web.at"]
  spec.description   = %q{Service registry for the new SOA ruby tool within the scope of the master thesis from Matthias Frick.}
  spec.summary       = %q{This gem provides a service registry to use within the new SOA ruby tool from Matthias Frick. This is a prototype under development within the scope of the master thesis from Matthias Frick.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-debugger"
  spec.add_development_dependency "debugger"
  
  spec.add_dependency "activemodel",  "~> 4.0.0"
  spec.add_dependency "typhoeus",     "~> 0.6.3"
end