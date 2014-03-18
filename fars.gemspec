# -*- encoding: utf-8 -*-
require File.expand_path('../lib/facewatch-internal/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Denyago', 'Lightpower']
  gem.email         = ["bva@aejis.eu"]
  gem.description   = %q{Fast ActiveRecord Serializer}
  gem.summary       = ""
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fars"
  gem.require_paths = ["lib"]
  gem.version       = Facewatch::Internal::VERSION

  gem.post_install_message = %{
Be sure to include latest rack-contrib in your Gemfile:

  gem 'rack-contrib', git: "https://github.com/rack/rack-contrib"

This is related to the parsing of POST'ed JSON.
  }

  gem.add_dependency  'activemodel',   '>= 3.2'
  gem.add_dependency  'activesupport', '>= 3.2'
  gem.add_dependency  'active_attr',   '>= 0.7.0'
  gem.add_dependency  'faraday',       '>= 0.8'
  gem.add_dependency  'rack-cors',     '>= 0.2'
  gem.add_dependency  'octokit',       '>= 1'
  gem.add_dependency  'airbrake',      '>= 3.1'

  gem.add_development_dependency 'rspec',        '>= 2.11'
  gem.add_development_dependency 'activerecord', '>= 3.2'
  gem.add_development_dependency 'activeresource', '>= 3.2'
  gem.add_development_dependency 'resque', '>= 1.24.0'
  gem.add_development_dependency 'resque-retry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sinatra', '>= 1.4.3'

end
