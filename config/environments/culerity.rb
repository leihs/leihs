#config.cache_classes = false
config.cache_classes = true # tpospise -> false breaks cucumber #

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :persistent

# http://github.com/langalex/culerity - enable testing of JavaScript views
config.gem "culerity"

system("jruby -e 'true'") or \
  raise "You need to have jruby installed on your $PATH"

`jruby -S gem list celerity` =~ /celerity/ or \
  raise "Please run 'jruby -S gem install celerity' to install Celerity inside jruby"

config.after_initialize do
  require 'culerity/persistent_delivery'
end

