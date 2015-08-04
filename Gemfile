source 'http://rubygems.org'

gem 'rails', '4.2.3'

gem 'activerecord-jdbcmysql-adapter', platform: :jruby
gem 'acts-as-dag', '~> 4.0' # alternative: 'dagnabit'
gem 'audited-activerecord', git: 'https://github.com/sellittf/audited.git' #, '~> 4.2'
gem 'barby', '~> 0.5.0'
gem "bower-rails", "~> 0.9" # $ rails g bower_rails:initialize
gem 'chunky_png', '~> 1.2'
gem 'coffee-rails', '~> 4.0'
gem 'coffee-script', '~> 2.2'
gem 'compass-rails', '~> 2.0'
gem 'execjs', '2.2.2' # NOTE '2.4.0' ExecJS::ProgramError: TypeError: Cannot set property 'root' of null (in /home/leihs/leihs-test/releases/20150410090031/vendor/assets/javascripts/spine/ajax.coffee)
gem 'font-awesome-rails', '~> 3.2.1' # NOTE in order to upgrade to '~> 4.0', use .fa css class instead of .icon
gem 'geocoder', '~> 1.1'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'haml', '~> 4.0'
gem 'haml_assets', '~> 0.2'
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'jquery-ui-rails', '~> 5.0'
gem 'jruby-openssl', platform: :jruby
gem 'json', '~> 1.8'
gem 'jsrender-rails', '~> 1.2', git: 'https://github.com/spape/jsrender-rails.git', branch: 'own_template_prefix'
gem 'libv8', '3.16.14.7'
gem 'liquid', '~> 3.0'
gem 'mini_magick', '~> 3.4'
gem 'money', '~> 6.5'
gem 'mysql2', '~> 0.3.11', platform: :mri
gem 'net-ldap', require: 'net/ldap'
gem 'nilify_blanks', '~> 1.1'
gem 'paperclip', '~> 4.3'
gem 'rails_autolink', '~> 1.0'
gem 'rake' # So that cronjobs work -- otherwise they can't find rake
gem 'rgl', '~> 0.4.0', require: 'rgl/adjacency' # use ruby-graphviz instead ?? (already in test group)
gem 'ruby_parser', '~> 3.1' # gettext dependency that Bundler seems unable to resolve
gem 'rubocop', require: false
gem 'sass-rails', '~> 4.0'
gem 'therubyracer', platform: :mri
gem 'therubyrhino', platform: :jruby
gem 'uglifier', '~> 2.4'
gem 'underscore-rails', '~> 1.7'
gem 'will_paginate', '~> 3.0'


group :development do
  gem 'capistrano', '2.15.5'
  gem 'capistrano-ext'
  gem 'capistrano-rbenv', '~> 1.0'
  gem 'metric_fu'
  gem 'thin', platform: :mri # web server (Webrick do not support keep-alive connections)
  gem 'traceroute'
  gem 'trinidad', platform: :jruby # web server (Webrick do not support keep-alive connections)
end

group :test do
  gem 'ladle'
  gem 'open4'
  gem 'rack_session_access', '~> 0.1.1'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'byebug' # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'cider_ci-support'
  gem 'cucumber-rails', '~> 1.3', require: false # it already includes capybara
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'faker', '1.3.0' # NOTE '~> 1.4' doesn't work beacause "I18n::InvalidLocale" error, see note for config.i18n in config/application.rb
  gem 'flog'
  gem 'flay'
  gem 'haml-lint'
  gem 'launchy', '~> 2.1'
  gem 'phantomjs', '~> 1.9.8' # headless webdriver (UI & JS tests)
  gem 'redcarpet' # This isn't being pulled in by yard, but it's required
  gem 'rspec-rails', '~> 3.0', require: false
  gem 'selenium-webdriver'
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'timecop', '~> 0.7'
  gem 'web-console', '~> 2.0' # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'yard'
end


