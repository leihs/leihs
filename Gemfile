source 'http://rubygems.org'

gem 'rails', '3.2.11' # FIXME cannot upgrade to 3.2.12 because migrations are not running

gem 'active_hash', '~> 0.9'
gem 'activerecord-jdbcmysql-adapter', :platform => :jruby
gem 'acts-as-dag', :git => 'git://github.com/jrust/acts-as-dag.git' #tmp# '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'
gem 'angular-ui-rails', '0.3.2' # '~> 0.3' # FIXME '0.4.0' not working
gem 'angularjs-rails', '~> 1.0'
gem 'barby', '~> 0.5.0'
gem 'better_errors', :group => :development
gem 'binding_of_caller', :group => :development
gem 'capybara', '1.1.2', :group => [:test, :development] # TODO upgrade to '~> 2.0'
gem 'capybara-screenshot', :group => [:test, :development]
gem 'chunky_png', '~> 1.2'
gem 'coffee-filter', '~> 0.1.1'
gem 'coffee-rails', '~> 3.2', :group => :assets
gem 'coffee-script', '~> 2.2'
gem 'compass-rails', '~> 1.0.3', :group => :assets
gem 'cucumber-rails', '~> 1.3', :group => [:test, :development], :require => false
gem 'database_cleaner', :group => [:test, :development]
gem 'factory_girl', '~> 4.1' # factories also in production mode to seed our demo data on the demo server
gem 'factory_girl_rails', '~> 4.1'
gem 'faker'
gem "font-awesome-sass-rails",  "~> 3.0.2.2",   :group => :assets
gem 'geocoder', '~> 1.1'
gem 'gettext_i18n_rails', '~> 0.8'
gem 'guard-jasmine', '~> 1.11', :group => [:test, :development]
gem 'haml', '~> 3.1'
gem 'haml_assets', '~> 0.2'
gem 'jasminerice', '~> 0.0.10', :group => [:test, :development] # needed for implement coffeescript, fixtures and asset pipeline serverd css into jasmine
gem 'jquery-rails', '2.1.3' # '~> 2.1' FIXME the version 2.1.4 clashes with underscore-rails 1.4.2.1
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'jruby-openssl', :platform => :jruby
gem 'json', '~> 1.7'
gem "jsrender-rails", "~> 1.2", :git => 'https://github.com/spape/jsrender-rails.git', :branch => "own_template_prefix"
gem 'launchy', '~> 2.1', :group => [:test, :development]
gem 'meta_request', :group => :development
gem 'mini_magick', '~> 3.4'
gem 'mysql2', '~> 0.3.11', :platform => :mri
gem 'nested_set', '~> 1.7'
gem 'net-ldap', '0.2.2', :require => 'net/ldap' # Never upgrade beyond 0.2.2, ruby-net-ldap has broken in many unpredictable ways. Wait for 1.0.0 before upgrading, at least 0.2.2 works.
gem 'newrelic_rpm', '~> 3.5', :group => [:profiling, :development]
gem 'paperclip'
gem 'phantomjs', '~> 1.6.0.0', :group => [:test, :development] # headless webdriver (UI & JS tests)
gem 'pry', '~> 0.9', :group => [:test, :development]
gem 'pry-rails', '~> 0.2', :group => [:test, :development]
gem 'rails_autolink', '~> 1.0'
gem 'rcapture', :group => :test
gem 'redcarpet', :group => [:test, :development] # This isn't being pulled in by yard, but it's required
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency' # use ruby-graphviz instead ?? (already in test group)
gem 'rspec', '~> 2.12', :group => [:test, :development], :require => false
gem 'rspec-rails', '~> 2.12', :group => [:test, :development], :require => false
gem 'ruby-graphviz', :group => :test
gem 'ruby_parser', '~> 3.1' # gettext dependency that Bundler seems unable to resolve
gem 'sass', '~> 3.2', :group => :assets
gem 'sass-rails', '~> 3.2', :group => :assets
gem 'selenium-webdriver', :group => [:test, :development]
gem 'therubyracer', :platform => :mri
gem 'therubyrhino', :platform => :jruby
gem 'thin', :group => :development, :platform => :mri # web server (Webrick do not support keep-alive connections)
gem 'timecop', '~> 0.5', :group => [:test, :development]
gem 'trinidad', :group => :development, :platform => :jruby # web server (Webrick do not support keep-alive connections)
gem 'uglifier', '~> 1.3', :group => :assets
gem 'underscore-rails', '~> 1.4'
gem 'uuidtools', '~> 2.1' # needed for creating unique ids during tests (factories)
gem 'will_paginate', :git => 'https://github.com/halloffame/will_paginate.git' # fixing count distinct, alternatives: .count(:id, :distinct => true)
gem 'yard', :group => [:test, :development]