# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_source/version'

Gem::Specification.new do |gem|
  gem.name          = "ruby-event_source"
  gem.version       = EventSource::VERSION
  gem.authors       = ["Pete Swan"]
  gem.email         = ["pete@indabamusic.com"]
  gem.description   = %q{EventSource client for use in threaded Ruby applications}
  gem.summary       = %q{Not everyone wants to use EventMachine}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency('rspec')
end
