source 'http://rubygems.org'

gem 'rails', '3.1.0.rc6'
gem 'builder', '~> 3.0' 
gem 'i18n', '~> 0.6.0' # Need this explicitly, otherwise can't deploy

gem 'unicorn'

gem 'mysql2', '~> 0.3.7'

#gem 'squeel', '~> 0.8.4'

# Asset template engines
gem 'json', '~> 1.5.3'
gem 'haml', '~> 3.1.2'
gem 'sass', '~> 3.1.5'
gem 'coffee-script'
gem 'uglifier', '~> 1.0.1'

gem 'prototype-rails', '~> 0.3.1', :git => 'git://github.com/rubychan/prototype-rails.git'
gem 'jquery-rails', '~> 1.0.13'
gem 'rails_autolink', '~> 1.0.2'

gem 'will_paginate', '~> 3.0'
gem 'thinking-sphinx', '~> 2.0.5', :require => 'thinking_sphinx'

gem 'gettext_i18n_rails', '~> 0.2.20'
gem 'ruby_parser', '~> 2.1.0' # gettext dependency that Bundler seems unable to resolve


gem 'barby', '0.4.3'
#gem "cairo" # Needed to print SVG barcodes
# gem "RubyInline", '3.8.2', :require => "inline"

gem 'rmagick', '~> 2.13.1', :require => 'RMagick' 
gem 'attachment_fu', :git => 'git://github.com/jmoses/attachment_fu.git', :branch => "rails3"

gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'
gem 'fastercsv', '~> 1.5.4'
#tmp# gem 'png', '~> 1.2.0'

gem 'prawn', '~> 0.12.0'
gem 'prawnto', '~> 0.0.4'

gem 'nested_set', '~> 1.6.7'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

gem 'geocoder', '~> 1.0.2'

group :profiling, :development do
	gem 'newrelic_rpm', '~> 3.1'
end

group :development do 
  gem 'gettext', '~> 2.1.0', :require => false 
end

group :cucumber, :development do
  gem 'ruby-debug19', :require => 'ruby-debug' # for Ruby 1.8.x: gem 'ruby-debug'
	gem 'require_relative' # ruby-debug requires linecache requires require_relative
end

group :cucumber, :test do
	gem 'cucumber-rails', '~> 1.0.2', :require => false
	gem 'database_cleaner', '~> 0.6.7', :require => false
	gem 'rspec', '~> 2.6.0', :require => false
	gem 'rspec-rails', '~> 2.6.1', :require => false
	gem 'nokogiri', '~> 1.5.0'
	gem 'capybara', '~> 1.0.1'
  gem 'launchy', '~> 2.0.4'
end

#group :culerity do
#	# http://github.com/langalex/culerity - enable testing of JavaScript views
#	gem "culerity"
#end
