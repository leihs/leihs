# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_leihs_session',
    :secret      => '8fcc8138d925274c30d5eb6b92299ddc448a25a1dc37f4974dcbe3995ca31f6482fe92554123506e15a7bf19ce1865d077abcff433c37bb6d3fc6eee8fb09d5a'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

# TODO 0603** upgrade Gettext
#  config.gem "gettext", :version => '1.93.0'
  config.gem "gettext", :version => ">=2.0.1"
  config.gem "locale", :version => ">=2.0.1"
#  config.gem "locale_rails", :version => ">=2.0.1"
#  config.gem "gettext_activerecord", :version => ">=2.0.1"
#  config.gem "gettext_rails", :version => ">=2.0.1"
 
  config.gem "barby", :version => '0.2.0'
  config.gem "png", :version => '1.1.0'

#  config.gem "RubyInline", :version => '3.8.1'
#  config.gem "topfunky-gruff", :version => '0.3.5'
#  config.gem "rmagick", :version => '2.9.1'
#  config.gem "rgl", :version => '0.4.0'
  config.gem "mislav-will_paginate", :lib => "will_paginate", :source => 'http://gems.github.com', :version => '>= 2.3.8'
  config.gem "freelancing-god-thinking-sphinx", :lib => "thinking_sphinx", :source => 'http://gems.github.com', :version => '>= 1.1.6'

  
end

# This ensures that a mongrel can start even if it's started
# by a user that is not the same user the mongrel runs as. In other words,
# if user 'leihs' should run the mongrel but you use user 'root' to start,
# this would usually fail since that user can't write to /root/.ruby_inline.
# This temp dir takes care of that.

temp = Tempfile.new('ruby_inline', '/tmp')
dir = temp.path
temp.delete
Dir.mkdir(dir, 0755)
ENV['INLINEDIR'] = dir

ActionMailer::Base.smtp_settings = {
  :address => "smtp.zhdk.ch",
  :port => 25,
  :domain => "beta.ausleihe.zhdk.ch"
}
ActionMailer::Base.default_charset = 'utf-8'



ENV['LC_CTYPE'] = 'en_US.UTF-8'
# TODO 2104** Prevent UTF-8 problems with Sphinx

# TODO **24 is this still right?
# E-Mail uncaught exceptions to the devs.
ExceptionNotifier.exception_recipients = %w( ramon.cahenzli@zhdk.ch errors@jeromemueller.ch )
ExceptionNotifier.sender_address = %( no-reply@hgkz.net )
ExceptionNotifier.email_prefix = "[leihs:ERROR] "

