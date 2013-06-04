# DOC: http://rubydoc.info/gems/rspec-rails/frames

require 'rubygems'

# Code coverage tool that supports Ruby 1.9 and Rails 3
# require 'simplecov'
# SimpleCov.start 'rails' do
#   merge_timeout 3600
# end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  # we want to reset everything before testing
  config.before :all do
    DatabaseCleaner.clean_with :truncation
  end

  # we have to clean everything after testing
  config.after :all do
    DatabaseCleaner.clean_with :truncation
  end
  
  config.before :each  do
    DatabaseCleaner.start
  end

  config.after :each  do
    DatabaseCleaner.clean
  end

end
