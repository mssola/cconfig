# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "cconfig/version"

Gem::Specification.new do |spec|
  spec.name          = "cconfig"
  spec.version       = CConfig::VERSION
  spec.authors       = ["mssola"]
  spec.email         = ["mssola@suse.com"]
  spec.description   = "Configuration management for container-aware applications"
  spec.summary       = "Configuration management for container-aware applications."
  spec.homepage      = "https://github.com/mssola/cconfig"
  spec.license       = "LGPL-3.0"

  spec.files         = `git ls-files`.split($RS)
  spec.test_files    = spec.files.grep("^spec/")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_dependency "safe_yaml", "~> 1.0.0", ">= 1.0.0"

  spec.add_development_dependency "bundler", ">= 1.0.0"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "rubocop", "~> 0.80.0"
  spec.add_development_dependency "rubocop-rspec"
end
