require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Leihs
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    #
    config.i18n.enforce_available_locales = false
    # The *correct* way to do this is this:
    #config.i18n.enforce_available_locales = true
    #config.i18n.available_locales = [:de_CH, :en_GB, :en_US, :es, :gsw_CH]
    # But the Faker gem is currently broken and does not accept properly spelled locales like 'en_US', it tries
    # to look for 'en' and that breaks. If Faker is ever fixed, we can uncomment the above lines.

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

  end
end

PER_PAGE = 20
