# -*- ruby -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Jarl Friis", "Kenneth Kalmer", "Michal Zima"]
  gem.email         = ["jarl@softace.dk"]
  gem.name          = 'activerecord-tableless'
  gem.summary       = %q{A library for implementing tableless ActiveRecord models}
  gem.description   = %q{ActiveRecord Tableless Models provides a simple mixin for creating models that are not bound to the database. This approach is mostly useful for capitalizing on the features ActiveRecord::Validation}
  gem.homepage      = "https://github.com/softace/activerecord-tableless"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.version       = "1.0.1"
  gem.has_rdoc      = true
  gem.extra_rdoc_files = %w( README CHANGELOG )
  gem.rdoc_options.concat ['--main',  'README']

  gem.require_paths = ["lib"]
  gem.platform      = Gem::Platform::RUBY

  gem.add_dependency("activerecord", ">= 3.0.0")

  gem.add_development_dependency('bundler')
  gem.add_development_dependency('rake')

  gem.add_development_dependency("rails", ">= 3.2.0")
  gem.add_development_dependency("jquery-rails", ">= 2.0")
  gem.add_development_dependency('sqlite3', '~> 1.3')

  gem.add_development_dependency('appraisal', '~> 0.4')
  gem.add_development_dependency('cucumber', '~> 1.1')
  gem.add_development_dependency('launchy', '~> 2.1')
  gem.add_development_dependency('aruba')
  gem.add_development_dependency('capybara')
end
