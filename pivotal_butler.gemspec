# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pivotal_butler/version'

Gem::Specification.new do |spec|
  spec.name          = "pivotal_butler"
  spec.version       = PivotalButler::VERSION
  spec.authors       = ["takehito sato"]
  spec.email         = ["takehitosato@gmail.com"]
  spec.description   = %q{pivotal butler is pivotal tracker bot for irc}
  spec.summary       = %q{pivotal tracker bot}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cinch"
  spec.add_dependency "pivotal-tracker"
  spec.add_dependency "settingslogic"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

end
