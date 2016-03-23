source 'http://rubygems.org'

gem 'leihs_admin', path: "engines/leihs_admin"
gem 'procurement', path: "engines/procurement"

gem 'rails', '4.2.6'

gem 'activerecord-jdbcmysql-adapter', platform: :jruby
gem 'acts-as-dag', '~> 4.0' # alternative: 'dagnabit'
gem 'audited-activerecord', git: 'https://github.com/sellittf/audited.git' #, '~> 4.2'
gem 'barby', '~> 0.5.0'
gem 'chunky_png', '~> 1.2'
gem 'coffee-rails', '~> 4.0'
gem 'coffee-script', '~> 2.2'
gem 'compass-rails', '~> 2.0'
gem 'execjs', '~> 2.6'
gem 'font-awesome-sass', '~> 4.4' # NOTE font not found using gem 'rails-assets-font-awesome'
gem 'geocoder', '~> 1.1'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'haml', '~> 4.0'
gem 'haml_assets', '~> 0.2'
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'jruby-openssl', platform: :jruby
gem 'json', '~> 1.8'
gem 'jsrender-rails', '~> 1.2', git: 'https://github.com/spape/jsrender-rails.git', branch: 'own_template_prefix'
gem 'liquid', '~> 3.0'
gem 'mini_magick', '~> 3.4'
gem 'money-rails', '~>1.4'
gem 'mysql2', '~> 0.4', platform: :mri
gem 'net-ldap', require: 'net/ldap'
gem 'nilify_blanks', '~> 1.1'
gem 'paperclip', '~> 4.3'
gem 'rails_autolink', '~> 1.0'
gem 'rake' # So that cronjobs work -- otherwise they can't find rake
gem 'rgl', '~> 0.4.0', require: 'rgl/adjacency' # use ruby-graphviz instead ?? (already in test group)
gem 'ruby_parser', '~> 3.1' # gettext dependency that Bundler seems unable to resolve
gem 'rubocop', '0.35.1', require: false
gem 'sass-rails', '~> 4.0'
gem 'therubyracer', platform: :mri
gem 'therubyrhino', platform: :jruby
gem 'uglifier', '~> 2.4'
gem 'will_paginate', '~> 3.0'

source 'https://rails-assets.org' do
  gem 'rails-assets-accounting.js', '~> 0.4'
  gem 'rails-assets-fullcalendar', '~> 1.5'
  gem 'rails-assets-jquery', '~> 1.5'
  gem 'rails-assets-jquery-autosize', '~> 1.18'
  gem 'rails-assets-jquery.inview', '1.0.0'
  gem 'rails-assets-jquery-ui', '~> 1.1'
  gem 'rails-assets-jquery-ujs', '~> 1.0'
  gem 'rails-assets-moment', '~> 2.10'
  gem 'rails-assets-timecop', '~> 0.1'
  gem 'rails-assets-underscore', '~> 1.8'
  gem 'rails-assets-uri.js', '~> 1.16'
end

group :development do
  gem 'capistrano', '2.15.5'
  gem 'capistrano-ext'
  gem 'capistrano-rbenv', '~> 1.0'
  gem 'metric_fu'
  gem 'thin', platform: :mri # web server (Webrick do not support keep-alive connections)
  gem 'traceroute'
  gem 'trinidad', platform: :jruby # web server (Webrick do not support keep-alive connections)
  gem 'web-console', '~> 2.0' # Access an IRB console on exception pages or by using <%= console %> in views
end

group :test do
  gem 'ladle'
  gem 'open4'
  gem 'rack_session_access', '~> 0.1.1'
  gem 'turnip'
end

group :development, :test do
  gem 'byebug' # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'cider_ci-support'
  gem 'cucumber-rails', '1.4.2', require: false # it already includes capybara # NOTE '~> 1.4' doesn't work beacause 'gherkin'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'faker', '1.3.0' # NOTE '~> 1.4' doesn't work beacause "I18n::InvalidLocale" error, see note for config.i18n in config/application.rb
  gem 'flog'
  gem 'flay'
  gem 'haml-lint'
  gem 'launchy', '~> 2.1'
  gem 'meta_request'
  gem 'phantomjs', '~> 2.1' # headless webdriver (UI & JS tests)
  gem 'pry'
  gem 'pry-rails'
  gem 'redcarpet' # This isn't being pulled in by yard, but it's required
  gem 'rspec-rails', '~> 3.0', require: false
  gem 'selenium-webdriver', '~> 2.53'
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'timecop', '~> 0.7'
  gem 'yard'
end


