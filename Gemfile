source 'http://rubygems.org'

gem 'rails', '3.2.3'

gem 'mysql2', '~> 0.3.11'
gem 'json', '~> 1.6'

gem 'haml', '~> 3.1'
gem 'sass', '~> 3.1'
gem 'coffee-script', '~> 2.2'
gem "coffee-filter", "~> 0.1.1"
gem 'jquery-rails', '~> 2.0'
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'haml_assets'

gem 'rails_autolink', '~> 1.0'
gem 'will_paginate', :git => "https://github.com/halloffame/will_paginate.git" # fixing count distinct, alternatives: .count(:id, :distinct => true)
#gem 'will_paginate', '~> 3.0' # alternatives: kaminari
gem 'gettext_i18n_rails', '~> 0.3'
gem 'ruby_parser', '~> 2.3' # gettext dependency that Bundler seems unable to resolve

gem 'barby', '~> 0.5.0'
gem "chunky_png", "~> 1.2.5"

gem 'mini_magick', '~> 3.3'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'
gem 'fastercsv', '~> 1.5.4'

gem 'nested_set', '~> 1.7'
gem 'acts-as-dag', :git => "git://github.com/jrust/acts-as-dag.git" #tmp# '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'
gem 'geocoder', '~> 1.1'
gem "underscore-rails", "~> 1.3.1"
# gem "RubyInline", '3.8.2', :require => "inline"

gem "acts_as_audited", :git => "git://github.com/sellittf/acts_as_audited.git" #"~> 2.1"

group :assets do # Gems used only for assets and not required in production environments by default.
  gem 'sass-rails', '~> 3.2'
  gem 'coffee-rails', '~> 3.2'
  gem 'uglifier', '~> 1.2'
end

group :development do
  gem 'thin' # web server (Webrick do not support keep-alive connections)
  gem 'gettext'
end

group :profiling, :development do
	gem 'newrelic_rpm', '~> 3.3'
end

group :test, :development do
  gem "growl", "~> 1.0.3"
  gem "guard", "~> 1.0.1"
  gem "guard-cucumber", "~> 0.8"
  gem "guard-rspec", "~> 0.7"
  gem "guard-spork", "~> 0.7"
  gem "guard-jasmine-headless-webkit", "~> 0.3.2"
  gem "jasmine-headless-webkit", "~> 0.8.4" # needed for "headless" running of jasmine tests (needed for CI)
  gem "jasmine-rails", "~> 0.0.2" # javascript test environment
  gem "jasminerice", "~> 0.0.8" # needed for implement coffeescript, fixtures and asset pipeline serverd css into jasmine
  gem "rb-fsevent", "~> 0.9"
  gem "ruby_gntp", "~> 0.3.4"
  gem 'factory_girl', "~> 3.0"
  gem 'factory_girl_rails', "~> 3.0"
  gem 'faker'
  gem 'pry', "~> 0.9"
  gem 'pry-rails', "~> 0.1"
  gem 'spork'
  gem 'cucumber-rails', '~> 1.2', :require => false
  gem 'database_cleaner', '~> 0.7', :require => false
  gem 'rspec', '~> 2.7', :require => false
  gem 'rspec-rails', '~> 2.7', :require => false
  gem 'nokogiri', '~> 1.5.0'
  gem 'capybara', '~> 1.1'
  gem 'simplecov'
  gem 'launchy', '~> 2.1'
  gem "uuidtools", "~> 2.1.2" # needed for creating unique ids during tests (factories)
  gem "timecop", "~> 0.3.5"
  gem 'capybara-screenshot'
end

#group :culerity do
# # http://github.com/langalex/culerity - enable testing of JavaScript views
# gem "culerity"
#end
