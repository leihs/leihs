if Rails.env.development? and ENV['TEST_DATETIME']
  require File.join(Rails.root, 'features/support/dataset.rb')
  puts `RAILS_ENV=development rake db:drop db:create`
  Dataset.restore_random_dump
end
