# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foundation/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "foundation-cli"
  spec.version       = Foundation::Cli::VERSION
  spec.authors       = ["Mark Hayes"]
  spec.email         = ["mark@zurb.com"]
  spec.description   = %q{A CLI for working with Foundation}
  spec.summary       = %q{The easiest way to get started with Foundation}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "thor", [">= 0.18.1"]
end
