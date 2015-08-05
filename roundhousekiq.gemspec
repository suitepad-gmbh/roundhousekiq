# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roundhousekiq/version'

Gem::Specification.new do |spec|
  spec.name          = "roundhousekiq"
  spec.version       = Roundhousekiq::VERSION
  spec.authors       = ["Moritz Lawitschka"]
  spec.email         = ["moritz.lawitschka@suitepad.de"]
  spec.summary       = %q{AMQP to Sidekiq bridge}
  spec.description   = %q{Trigger Sidekiq jobs asynchronously over AMQP}
  spec.homepage      = "https://github.com/suitepad-gmbh/roundhousekiq"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ['roundhousekiq']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bunny", "~> 1.7"
  spec.add_dependency "sidekiq", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "rspec-nc", "~> 0.2.0"
  spec.add_development_dependency "guard", "~> 2.13.0"
  spec.add_development_dependency "guard-rspec", "~> 4.6.4"
  spec.add_development_dependency "codeclimate-test-reporter"
end
