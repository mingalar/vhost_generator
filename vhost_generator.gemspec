# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vhost_generator/version'

Gem::Specification.new do |gem|
  gem.name          = "vhost_generator"
  gem.version       = VhostGenerator::VERSION
  gem.authors       = ["Julien Pervillé"]
  gem.email         = ["julien.perville@mingalar.fr"]
  gem.description   = ['vhost_generator outputs a general-purpose VirtualHost',
                       'configuration file to run your web application behind',
                       'an nginx or apache frontend'].join(' ')
  gem.summary       = ['vhost_generator outputs nginx or apache VirtualHost',
                       'configurations to run your web application'].join(' ')
  gem.homepage      = "https://github.com/mingalar/vhost_generator"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency('dotenv', '~> 0.2.0')
  gem.add_development_dependency('rake', '~> 0.9.2.2')
  gem.add_development_dependency('cucumber', '~> 1.2.1')
  gem.add_development_dependency('aruba', '~> 0.4.11')
  gem.add_development_dependency('rspec', '~> 2.11.0')
end
