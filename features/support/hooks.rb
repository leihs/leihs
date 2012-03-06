Before do
  DatabaseCleaner.start

  # require our factory
#  require "#{Rails.root}/features/support/leihs_factory.rb"
#  LeihsFactory.create_minimal_setup
end

After do |scenario|
  DatabaseCleaner.clean
end