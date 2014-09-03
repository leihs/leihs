if Rails.env.development? and ENV['TEST_DATETIME']
  DatabaseCleaner.clean_with :truncation

  require File.join(Rails.root, 'features/support/personas.rb')
  require File.join(Rails.root, 'features/support/timecop.rb')

  Persona.use_test_datetime(ENV['TEST_DATETIME'])
  Persona.restore_random_dump
end
