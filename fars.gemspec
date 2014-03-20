# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fars/version', __FILE__)

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
  gem.version       = Fars::VERSION

  gem.add_dependency  'activerecord',  '>= 3.2'

  gem.add_development_dependency 'rspec',        '>= 2.11'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'shoulda'
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'database_cleaner'

end
