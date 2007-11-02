# Be sure to restart your webserver when you modify this file.

# Uncomment below to force Rails into production mode
# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] = 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/app/services )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
Inflector.inflections do |inflect|
	inflect.irregular 'logeintrag', 'logeintraege'
	inflect.uncountable 'zubehoer'
end

# Include your application configuration below

# Konfiguration des ActionMailers
ActionMailer::Base.smtp_settings = {
	:address => "smtp.zhdk.ch",
	:port => 25,
	:domain => "ausleihe.zhdk.ch"
}
ActionMailer::Base.default_charset = 'utf-8'

# CalendarDateSelect has only a limited number of date formats that work
CalendarDateSelect.format = :hyphen_ampm


# This creates a span instead of a div around fields with errors.
# The advantage is that with a span, no newline is added after an error
# field, so the CSS does not have to be changed to "inline" to prevent this
#ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
#"<span class=\"fieldWithErrors\">#{html_tag}</span>" }
