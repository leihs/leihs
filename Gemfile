source 'http://rubygems.org'

gem 'rails', '4.0.9'

gem 'activerecord-jdbcmysql-adapter', platform: :jruby
gem 'acts-as-dag', '~> 4.0' # alternative: 'dagnabit'
gem 'audited-activerecord', git: 'https://github.com/sellittf/audited.git' #, '~> 4.2'
gem 'barby', '~> 0.5.0'
gem 'better_errors', group: :development
gem 'binding_of_caller', group: :development
gem "bower-rails", "~> 0.9" # $ rails g bower_rails:initialize
gem 'capistrano', '2.15.5', group: :development
gem 'capistrano-ext', group: :development
gem 'capistrano-rbenv', '~> 1.0', group: :development
gem 'chunky_png', '~> 1.2'
gem 'cider_ci-support', group: [:test, :development]
gem 'coffee-rails', '~> 4.0'
gem 'coffee-script', '~> 2.2'
gem 'compass-rails', '~> 1.1'
gem 'cucumber-rails', '~> 1.3', group: [:test, :development], require: false # it already includes capybara
gem 'database_cleaner', group: [:test, :development]
gem 'execjs', '2.2.2' # NOTE '2.4.0' ExecJS::ProgramError: TypeError: Cannot set property 'root' of null (in /home/leihs/leihs-test/releases/20150410090031/vendor/assets/javascripts/spine/ajax.coffee)
gem 'factory_girl_rails', '~> 4.1', group: [:test, :development]
gem 'faker', '1.3.0', group: [:test, :development] # NOTE '~> 1.4' doesn't work beacause "I18n::InvalidLocale" error, see note for config.i18n in config/application.rb
gem 'flog', group: [:test, :development]
gem 'flay', group: [:test, :development]
gem 'font-awesome-rails', '~> 3.2.1' # NOTE in order to upgrade to '~> 4.0', use .fa css class instead of .icon
gem 'foreigner', '~> 1.6'
gem 'geocoder', '~> 1.1'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'haml', '~> 4.0'
gem 'haml_assets', '~> 0.2'
gem 'haml-lint', group: [:test, :development]
gem 'i18n', '0.6.11'
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'jquery-ui-rails', '~> 5.0'
gem 'jruby-openssl', platform: :jruby
gem 'json', '~> 1.8'
gem 'jsrender-rails', '~> 1.2', git: 'https://github.com/spape/jsrender-rails.git', branch: 'own_template_prefix'
gem 'ladle', group: :test
gem 'launchy', '~> 2.1', group: [:test, :development]
gem 'liquid', '~> 3.0'
gem 'meta_request', group: :development
gem 'metric_fu', group: :development
gem 'mini_magick', '~> 3.4'
gem 'money', '~> 6.5'
gem 'mysql2', '~> 0.3.11', platform: :mri
gem 'net-ldap', require: 'net/ldap'
gem 'nilify_blanks', '~> 1.1'
gem 'open4', group: :test
gem 'paperclip', '~> 3.5' # NOTE in order to upgrate to '~> 4.0', first adapt the code to avoid the Paperclip::Errors::MissingRequiredValidatorError
gem 'phantomjs', '~> 1.9.8', group: [:test, :development] # headless webdriver (UI & JS tests)
gem 'protected_attributes', '~> 1.0'
gem 'pry-byebug', group: [:test, :development]
gem 'pry-rails', group: [:test, :development]
gem 'rack_session_access', '~> 0.1.1', group: :test
gem 'rails_autolink', '~> 1.0'
gem 'rake' # So that cronjobs work -- otherwise they can't find rake
gem 'redcarpet', group: [:test, :development] # This isn't being pulled in by yard, but it's required
gem 'rgl', '~> 0.4.0', require: 'rgl/adjacency' # use ruby-graphviz instead ?? (already in test group)
gem 'rspec-rails', '~> 3.0', group: [:test, :development], require: false
gem 'ruby_parser', '~> 3.1' # gettext dependency that Bundler seems unable to resolve
gem 'rubocop', require: false
gem 'sass-rails', '~> 4.0'
gem 'selenium-webdriver', group: [:test, :development]
gem 'simplecov', require: false, group: :test
gem 'therubyracer', platform: :mri
gem 'therubyrhino', platform: :jruby
gem 'thin', group: :development, platform: :mri # web server (Webrick do not support keep-alive connections)
gem 'timecop', '~> 0.7', group: [:test, :development]
gem 'trinidad', group: :development, platform: :jruby # web server (Webrick do not support keep-alive connections)
gem 'uglifier', '~> 2.4'
gem 'underscore-rails', '~> 1.7'
gem 'will_paginate', '~> 3.0'
gem 'yard', group: [:test, :development]
