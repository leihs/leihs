# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.15' unless defined? RAILS_GEM_VERSION

# http://makandra.com/notes/1051-fixing-uninitialized-constant-activesupport-dependencies-mutex-nameerror
require 'thread'

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

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :"availability/observer"

  config.cache_store = :mem_cache_store, {:namespace => "leihs_#{RAILS_ENV}_#{Time.now.to_i}"}

# 2901
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
#  config.i18n.load_path = Dir[File.join(RAILS_ROOT, 'config', 'locales', '*.{rb,yml}')]
#  config.i18n.default_locale = :de_CH

# TODO 2012
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Bern'
end

require 'looks_like_email_addr'

######################################################
# This ensures that a mongrel can start even if it's started
# by a user that is not the same user the mongrel runs as. In other words,
# if user 'leihs' should run the mongrel but you use user 'root' to start,
# this would usually fail since that user can't write to /root/.ruby_inline.
# This temp dir takes care of that.

#temp = Tempfile.new('ruby_inline', '/tmp')
#dir = temp.path
#temp.delete
#Dir.mkdir(dir, 0755)
#ENV['INLINEDIR'] = dir

# Necessary to prevent this error:
# http://www.viget.com/extend/rubyinline-in-shared-rails-environments/
ENV['INLINEDIR'] = "#{RAILS_ROOT}/tmp/"
######################################################

ActionMailer::Base.smtp_settings = {
  :address => "smtp.zhdk.ch",
  :port => 25,
  :domain => "beta.ausleihe.zhdk.ch"
}
ActionMailer::Base.default_charset = 'utf-8'

#old#
#require 'ferret'
## Prevent UTF-8 problems with acts_as_ferret
#ENV['LC_CTYPE'] = 'en_US.UTF-8'
#Ferret.locale = "en_US.UTF-8"

# E-Mail uncaught exceptions to the devs.
ExceptionNotifier.exception_recipients = %w( ramon.cahenzli@zhdk.ch errors@jeromemueller.ch )
ExceptionNotifier.sender_address = %( no-reply@zhdk.ch )
ExceptionNotifier.email_prefix = "[leihs:ERROR] "

######################################################
# Settings

FRONTEND_SPLASH_PAGE = false

# This currency string is used on value lists. leihs itself has no capability
# to deal with currencies, any numbers used as values for items are just "n pieces of currency"
LOCAL_CURRENCY_STRING = "CHF"

# These terms are printed at the bottom of lending contracts.
CONTRACT_TERMS = "Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der Künste und darf ausschliesslich für schulische Zwecke eingesetzt werden. Mit ihrer/seiner Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die 'Richtlinie zur Ausleihe von Sachen' der ZHdK und etwaige abteilungsspezifische Ausleih-Richtlinien."

# This is used as address block on the top of contracts. Use \n if you
# want to create a line break.
CONTRACT_LENDING_PARTY_STRING = "Your\nAddress\nHere"

# This is appended to the bottom of e-mails sent by the system
EMAIL_SIGNATURE = "Das PZ-leihs Team"

# The file we get our LDAP configuration from
LDAP_CONFIG = YAML::load_file(RAILS_ROOT+'/config/LDAP.yml')

# The email address that inventory pool related messages are sent to
# if no inventory pool specific address has been set in the backend
DEFAULT_EMAIL = 'sender@example.com'

# Send a notification to the e-mail address of the inventory
# pool when this inventory pool receives an order? If the
# inventory pool has no address set, messages go to DEFAULT_EMAIL
DELIVER_ORDER_NOTIFICATIONS = false

######################################################
