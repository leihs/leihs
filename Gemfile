source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'builder', '~> 3.0' 
gem 'i18n', '~> 0.6.0' # Need this explicitly, otherwise can't deploy

#tmp# gem 'unicorn'

gem 'mysql2', '~> 0.3.7'
#tmp# gem 'squeel', '~> 0.8.4'

# Asset template engines
gem 'json', '~> 1.6'
gem 'haml', '~> 3.1'
gem 'sass', '~> 3.1.7'
gem 'sass-rails'
gem 'coffee-script'
gem 'uglifier', '~> 1.0'

#old# gem 'prototype-rails', '~> 0.3.1', :git => 'git://github.com/rubychan/prototype-rails.git'
gem 'jquery-rails', '~> 1.0'
gem 'jquery-tmpl-rails', '~> 0.1'
gem 'rails_autolink', '~> 1.0.2'

gem 'will_paginate', '~> 3.0'
gem 'thinking-sphinx', '~> 2.0.7', :require => 'thinking_sphinx'

gem 'gettext_i18n_rails', '~> 0.3'
gem 'ruby_parser', '~> 2.3' # gettext dependency that Bundler seems unable to resolve


gem 'barby', '~> 0.5.0'
#gem "cairo" # Needed to print SVG barcodes
# gem "RubyInline", '3.8.2', :require => "inline"

gem 'mini_magick', '~> 3.3'

gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'
gem 'fastercsv', '~> 1.5.4'
#tmp# gem 'png', '~> 1.2.0'

#. Let's stop using PDF.
gem 'prawn', '~> 0.12.0'
gem 'prawnto', '~> 0.0.4'

gem 'nested_set', '~> 1.6.8'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

gem 'geocoder', '~> 1.0'

group :profiling, :development do
	gem 'newrelic_rpm', '~> 3.1'
end

group :development do 
  gem 'gettext', '~> 2.1.0', :require => false 
end

group :cucumber, :development do
  gem 'pry' #gem 'ruby-debug19', '~> 0.11.6', :require => 'ruby-debug'
end

group :cucumber, :test do
	gem 'cucumber-rails', '~> 1.0', :require => false
	gem 'database_cleaner', '~> 0.6.7', :require => false
	gem 'rspec', '~> 2.6.0', :require => false
	gem 'rspec-rails', '~> 2.6.1', :require => false
	gem 'nokogiri', '~> 1.5.0'
	gem 'capybara', '~> 1.0'
  gem 'launchy', '~> 2.0.5'
end

#group :culerity do
#	# http://github.com/langalex/culerity - enable testing of JavaScript views
#	gem "culerity"
#end
