source 'http://rubygems.org'

gem 'rails', '3.1.0.rc1' #Rails3.1# '3.0.7' 
gem 'builder', '~> 3.0' #Rails3.1# '~> 2.1.2' 
gem 'i18n' # Need this explicitly, otherwise can't deploy
gem 'rake', '~> 0.9.2'

gem 'mysql2', '~> 0.3.2' #Rails3.1# '~> 0.2.7' 
#gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

# Asset template engines
gem 'json', '~> 1.5.1'
gem 'haml', '~> 3.1.1'
gem 'sass', '~> 3.1.2'
#Rails3.1# gem 'coffee-script'
#Rails3.1# gem 'uglifier'

gem 'prototype-rails', '~> 0.3.1'
#tmp# gem 'jquery-rails', '~> 1.0'
gem 'rails_autolink', '~> 1.0.1' #Rails3.1#

gem 'will_paginate', :git => 'git://github.com/JackDanger/will_paginate.git' #Rails3.1# fix for CollectionAssociation # '~> 3.0.pre2' 
#gem 'thinking-sphinx', :git => 'git://github.com/sylogix/thinking-sphinx.git', :branch => "rails3", :require => 'thinking_sphinx' #Rails 3.1# fix for JoinDependency
gem 'thinking-sphinx', '~> 2.0.5', :require => 'thinking_sphinx'

gem 'gettext', '~> 2.1.0', :require => false # TODO only for development ??
gem 'gettext_i18n_rails', '~> 0.2.20'

gem 'barby', '~> 0.4.3'
#gem "cairo" # Needed to print SVG barcodes
# gem "RubyInline", '3.8.2', :require => "inline"

gem 'rmagick', '~> 2.13.1', :require => 'RMagick' 
gem 'attachment_fu', :git => 'git://github.com/jmoses/attachment_fu.git', :branch => "rails3"

gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'
gem 'fastercsv', '~> 1.5.4'
#tmp# gem 'png', '~> 1.2.0'

gem 'prawn', '~> 0.11.1'
gem 'prawnto', '~> 0.0.4'

gem 'nested_set', '~> 1.6.6'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

group :profiling do
	gem 'newrelic_rpm', '~> 3.0.1'
end

group :cucumber, :development do
	gem 'ruby-debug', '~> 0.10.4' #Rails3.1# , :require => false
end

group :cucumber, :test do
	gem 'cucumber-rails', '~> 0.5.0', :require => false
	gem 'database_cleaner', '~> 0.6.7', :require => false
	gem 'rspec', '~> 2.6.0', :require => false
	gem 'rspec-rails', '~> 2.6.1', :require => false
	gem 'nokogiri', '~> 1.4.4'
	gem 'capybara', '1.0.0.beta1'
  gem 'launchy', '~> 0.4.0'
end

#group :culerity do
#	# http://github.com/langalex/culerity - enable testing of JavaScript views
#	gem "culerity"
#end
