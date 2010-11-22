source 'http://rubygems.org'

gem 'rails', '2.3.5'

gem 'mysql'

gem "gettext", "2.1.0"
# 2901 gem "locale_rails", '2.0.5' # see config/initializers/gettext.rb
gem "gettext_activerecord", '2.1.0'
gem "gettext_rails", '2.1.0'

gem "barby", '0.2.0'
gem "hoptoad_notifier", '2.3.8'
# gem "RubyInline", '3.8.2', :require => "inline"

# gem "rmagick", '2.7.0'
gem "rgl", "0.4.0", :require => "rgl/adjacency"
gem "will_paginate", '2.3.15'
gem "thinking-sphinx", '1.3.20', :require => 'thinking_sphinx'

gem "fastercsv", '1.5.3'

gem "prawn", '0.8.4'
gem "ruby-net-ldap", "0.0.4", :require => 'net/ldap'

gem "awesome_nested_set", "1.4.3"


group :profiling do
	gem "newrelic_rpm", '2.10.5'
end

group :cucumber do
	gem 'cucumber-rails', '>=0.2.4', :require => false # unless File.directory?(File.join(Rails.root, 'vendor/plugins/cucumber-rails'))
	gem 'database_cleaner', '>=0.4.3', :require => false # unless File.directory?(File.join(Rails.root, 'vendor/plugins/database_cleaner'))
	gem 'rspec', '>=1.3.0', :require => false # unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
	gem 'rspec-rails', '>=1.3.2', :require => false # unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
end

group :culerity do
	# http://github.com/langalex/culerity - enable testing of JavaScript views
	gem "culerity"
end
