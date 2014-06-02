source 'http://rubygems.org'

gem 'rails', '4.0.4'

gem 'active_hash', '~> 1.3'
gem 'activerecord-jdbcmysql-adapter', :platform => :jruby
gem 'acts-as-dag', :git => 'https://github.com/jheiss/acts-as-dag.git', :branch => 'rails4' # TOOD use instead ?? gem 'dagnabit', '2.2.6'
gem 'barby', '~> 0.5.0'
gem 'better_errors', :group => :development
gem 'binding_of_caller', :group => :development
gem 'capistrano', '2.15.5', :group => :development
gem 'capistrano-ext', :group => :development
#gem 'rvm-capistrano', :group => :development
gem 'capistrano-rbenv', '~> 1.0', :group => :development

gem "jasminerice", :git => 'https://github.com/bradphelan/jasminerice.git', :group => [:test, :development] # needed for implement coffeescript, fixtures and asset pipeline serverd css into jasmine
gem "rack_session_access", "~> 0.1.1", group: :test
gem 'capybara', '~> 2.2', :group => [:test, :development]
gem 'capybara-screenshot', :group => [:test, :development]
gem 'chunky_png', '~> 1.2'
gem 'coffee-filter', '~> 0.1.1'
gem 'coffee-rails', '~> 4.0'
gem 'coffee-script', '~> 2.2'
gem 'compass-rails', '~> 1.1'
gem 'cucumber-rails', '~> 1.3', :group => [:test, :development], :require => false
gem 'database_cleaner', :group => [:test, :development]
gem 'execjs'
gem 'factory_girl', '~> 4.1', :groups => [:test, :development]
gem 'factory_girl_rails', '~> 4.1', :groups => [:test, :development]
gem 'faker', :groups => [:test, :development]
gem 'font-awesome-rails', '~> 3.2.1' # NOTE in order to upgrade to '~> 4.0', use .fa css class instead of .icon
gem 'geocoder', '~> 1.1'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'guard-jasmine', '~> 1.19', :group => [:test, :development]
gem 'haml', '~> 3.1'
gem 'haml_assets', '~> 0.2'
gem 'jquery-rails', '2.1.3' # '~> 2.1' FIXME the version 2.1.4 clashes with underscore-rails 1.4.2.1 + # NOTE in order to upgrate to '~> 3.1', first adapt the code removing the .live() functions
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'jruby-openssl', :platform => :jruby
gem 'json', '~> 1.8'
gem 'jsrender-rails', '~> 1.2', :git => 'https://github.com/spape/jsrender-rails.git', :branch => 'own_template_prefix'
gem 'ladle', :group => :test
gem 'launchy', '~> 2.1', :group => [:test, :development]
gem 'meta_request', :group => :development
gem 'mini_magick', '~> 3.4'
gem 'mysql2', '~> 0.3.11', :platform => :mri
#gem 'net-ldap', '0.2.2', :require => 'net/ldap' # Never upgrade beyond 0.2.2, ruby-net-ldap has broken in many unpredictable ways. Wait for 1.0.0 before upgrading, at least 0.2.2 works.
gem 'net-ldap', :require => 'net/ldap'
gem 'newrelic_rpm', '~> 3.5'
gem 'paperclip', '~> 3.5' # NOTE in order to upgrate to '~> 4.0', first adapt the code to avoid the Paperclip::Errors::MissingRequiredValidatorError
gem 'phantomjs', '~> 1.9.7', :group => [:test, :development] # headless webdriver (UI & JS tests)
gem 'poltergeist'
gem 'protected_attributes', '~> 1.0'
gem 'pry', :group => [:test, :development]
gem 'pry-debugger', :group => :development
gem 'pry-rails', :group => [:test, :development]
gem 'rails_autolink', '~> 1.0'
gem 'rake' # So that cronjobs work -- otherwise they can't find rake
gem 'redcarpet', :group => [:test, :development] # This isn't being pulled in by yard, but it's required
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency' # use ruby-graphviz instead ?? (already in test group)
gem 'rspec', '~> 2.12', :group => [:test, :development], :require => false
gem 'rspec-rails', '~> 2.12', :group => [:test, :development], :require => false
gem 'ruby_parser', '~> 3.1' # gettext dependency that Bundler seems unable to resolve
gem 'sass', '~> 3.2'
gem 'sass-rails', '~> 4.0'
gem 'selenium-webdriver', :group => [:test, :development]
#gem 'simplecov', :require => false, :group => :test
gem 'therubyracer', :platform => :mri
gem 'therubyrhino', :platform => :jruby
gem 'thin', :group => :development, :platform => :mri # web server (Webrick do not support keep-alive connections)
gem 'timecop', '~> 0.7', :group => [:test, :development]
gem 'trinidad', :group => :development, :platform => :jruby # web server (Webrick do not support keep-alive connections)
gem 'uglifier', '~> 2.4'
gem 'underscore-rails', '~> 1.6'
gem 'will_paginate', '~> 3.0'
gem 'yard', :group => [:test, :development]
