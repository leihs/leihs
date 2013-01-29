# === PLEASE NOTE ===
# RubyGems and the various gems listed here have MANY incompatibilities
# with each other. Therefore, you must use a specific version of RubyGems
# to install them (sorry, not our fault!)
#
# Please use only RubyGems version 1.5.2 to install these gems.
# === PLEASE NOTE ===

source 'http://rubygems.org'

gem 'rails', '2.3.5'
gem 'rake', '0.8.7'
gem 'json'

gem 'mysql', '2.8.1'
#gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

# This version is incompatible with RubyGems 1.8+
gem "gettext", "2.1.0"

# 2901 gem "locale_rails", '2.0.5' # see config/initializers/gettext.rb
gem "gettext_activerecord", '2.1.0'
gem "gettext_rails", '2.1.0'

gem "barby", '0.2.0'
gem "pkg-config", '1.1.2'
gem "cairo", '1.10.2' # Needed to print SVG barcodes
# gem "RubyInline", '3.8.2', :require => "inline"

gem "rmagick", '2.12.2', :require => 'RMagick'
gem "rgl", "0.4.0", :require => "rgl/adjacency"
gem "will_paginate", '2.3.15'
gem "thinking-sphinx", '1.3.20', :require => 'thinking_sphinx'
gem "riddle", '1.4.0' # Don't use newer versions, it breaks

gem "fastercsv", '1.5.3'

gem "prawn", '0.8.4'
gem "net-ldap", '0.2.2', :require => 'net/ldap'

gem "awesome_nested_set", "1.4.3"
gem 'acts-as-dag', '1.1.4' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

gem "haml", '3.1.3'


group :profiling do
	gem "newrelic_rpm", '2.10.5'
end

group :cucumber, :development do
	gem 'ruby-debug', '0.10.4', :require => false
end

group :cucumber, :test do
	gem 'cucumber-rails', '0.3.2', :require => false
	gem 'database_cleaner', '0.5.0', :require => false
	gem 'rspec', '1.3.0', :require => false
	gem 'rspec-rails', '1.3.2', :require => false
	gem 'nokogiri', '1.5.2'
  gem 'capybara', '1.1.2'
  gem 'launchy', '2.0.5'
end

#group :culerity do
#	# http://github.com/langalex/culerity - enable testing of JavaScript views
#	gem "culerity"
#end
