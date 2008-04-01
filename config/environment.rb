# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

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
end


# Configuration for ActionMailer
ActionMailer::Base.smtp_settings = {
  :address => "smtp.zhdk.ch",
  :port => 25,
  :domain => "ausleihe.zhdk.ch"
}
ActionMailer::Base.default_charset = 'utf-8'


class ActiveRecord::Base
  def to_i
    self.id
  end
end

# E-Mail uncaught exceptions to the devs.
ExceptionNotifier.exception_recipients = %w( magnus.rembold@munterbund.de ramon.cahenzli@zhdk.ch errors@jeromemueller.ch )
ExceptionNotifier.sender_address = %( no-reply@hgkz.net )
ExceptionNotifier.email_prefix = "[leihs:ERROR] "

# We want gettext functionality.
require 'gettext/rails'


