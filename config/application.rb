# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Leihs
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Bern'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.precompile += %w( simile_timeline/*
                                    i18n/locale/*
                                    splash.css
                                    shared.js
                                    backend.css
                                    backend.js
                                    frontend.css
                                    frontend.js
                                    print.css
                                    timeline.css
                                    application.js
                                    borrow.js
                                    application.css
                                  )
    # Enable IdentityMap for Active Record, to disable set to false or remove the line below.  
    # config.active_record.identity_map = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end

########################################################################
#rails3#

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
ENV['INLINEDIR'] = "#{Rails.root}/tmp/"
######################################################

ActionMailer::Base.smtp_settings = {
  :address => "smtp.zhdk.ch",
  :port => 25,
  :domain => "beta.ausleihe.zhdk.ch"
}
ActionMailer::Base.default :charset => 'utf-8'

######################################################
# Settings

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
#LDAP_CONFIG = YAML::load_file("#{Rails.root}/config/LDAP.yml")

# The email address that inventory pool related messages are sent to
# if no inventory pool specific address has been set in the backend
DEFAULT_EMAIL = 'sender@example.com'

# Send a notification to the e-mail address of the inventory
# pool when this inventory pool receives an order? If the
# inventory pool has no address set, messages go to DEFAULT_EMAIL
DELIVER_ORDER_NOTIFICATIONS = false

USER_IMAGE_URL = "http://www.zhdk.ch/?person/foto&width=100&compressionlevel=0&id={:id}"

PER_PAGE = 20

######################################################
