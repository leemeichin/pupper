# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pupper/version'

Gem::Specification.new do |spec|
  spec.name          = 'pupper'
  spec.version       = Pupper::VERSION
  spec.authors       = ['Lee Machin']
  spec.email         = ['lee@typeform.com']
  spec.summary       = 'Interact with APIs as if they were ActiveRecord models.'
  spec.homepage      = 'https://github.com/leemachin/pupper'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'activesupport', '~> 5.0'
  spec.add_dependency 'activemodel', '~> 5.0'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'typhoeus'
  spec.add_dependency 'oj'
end
