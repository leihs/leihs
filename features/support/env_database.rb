# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation, {:except => %w[authentication_systems languages roles]} #sellittf#

# require our factory
require("#{Rails.root}/lib/leihs_factory.rb")

LeihsFactory.create_minimal_setup
