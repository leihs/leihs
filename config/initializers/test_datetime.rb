if Rails.env.development? and ENV['TEST_DATETIME']
  require File.join(Rails.root, 'features/support/dataset.rb')
  Dataset.restore_random_dump
end
