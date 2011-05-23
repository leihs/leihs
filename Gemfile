source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'builder', '~> 2.1.2'
#gem 'i18n'
gem 'rake', '~> 0.8.7' # version 0.9.0 is broken!

gem 'mysql2', '~> 0.2.7'
#gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

gem 'gettext', '~> 2.1.0', :require => false
gem 'gettext_i18n_rails', '~> 0.2.19'

gem 'barby', '~> 0.4.3'
#gem "cairo" # Needed to print SVG barcodes
# gem "RubyInline", '3.8.2', :require => "inline"

gem 'rmagick', '~> 2.13.1', :require => 'RMagick' 
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'will_paginate', '~> 3.0.pre2'
gem 'thinking-sphinx', '~> 2.0.4', :require => 'thinking_sphinx'

gem 'fastercsv', '~> 1.5.4'

gem 'prawn', '~> 0.11.1'
gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'

gem 'nested_set', '~> 1.6.4'

gem 'haml', '~> 3.1.1'
gem 'sass', '~> 3.1.1'

group :profiling do
	gem 'newrelic_rpm', '~> 3.0.0'
end

group :cucumber, :development do
	gem 'ruby-debug', '~> 0.10.4', :require => false
end

group :cucumber, :test do
	gem 'cucumber-rails', '~> 0.5.0', :require => false
	gem 'database_cleaner', '~> 0.6.7', :require => false
	gem 'rspec', '~> 2.6.0', :require => false
	gem 'rspec-rails', '~> 2.6.0', :require => false
	gem 'nokogiri', '~> 1.4.4'
	gem 'capybara', '1.0.0.beta1'
  gem 'launchy', '~> 0.4.0'
end

#group :culerity do
#	# http://github.com/langalex/culerity - enable testing of JavaScript views
#	gem "culerity"
#end
