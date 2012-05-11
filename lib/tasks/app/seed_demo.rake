namespace :app do

  namespace :seed do

    desc "Seed the app with data"
    task :demo => :environment do
      puts "[START] Seeding the database"
      require "factory_girl"
      require "faker"
      require 'pry'
      FactoryGirl.find_definitions 
      puts "[END] Seeding the database"
    end
  end
end