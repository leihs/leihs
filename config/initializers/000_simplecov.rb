if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails' do
    merge_timeout 6000
  end
  puts "required simplecov"
end

#SimpleCov.at_exit do
#  #FileUtils.mv(File.join(Rails.root, "coverage", ".resultset.json"), File.join(Rails.root, "coverage", "cider-resultset.json"))
#end

