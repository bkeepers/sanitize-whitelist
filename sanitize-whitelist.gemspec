# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sanitize/whitelist/version'

Gem::Specification.new do |spec|
  spec.name          = "sanitize-whitelist"
  spec.version       = Sanitize::Whitelist::VERSION
  spec.authors       = ["Brandon Keepers"]
  spec.email         = ["brandon@opensoul.org"]
  spec.summary       = %q{Objects to represent a whitelist that can be used by the sanitize gem.}
  spec.description   = %q{Objects to represent a whitelist that can be used by the sanitize gem.}
  spec.homepage      = "https://github.com/bkeepers/sanitize-whitelist"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
