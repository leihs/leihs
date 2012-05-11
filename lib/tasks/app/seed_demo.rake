namespace :app do

  namespace :seed do

    desc "Seed the app with data"
    task :demo => :environment do
      puts "[START] Seeding the database"
      require "factory_girl"
      require "faker"
      require 'pry'
      #FactoryGirl.find_definitions

      customer_role = Role.where(:name => 'customer').first
      admin_role = Role.where(:name => 'admin').first
      manager_role = Role.where(:name => 'manager').first
      
      ip1 = FactoryGirl.create(:inventory_pool, :name => 'Main Building')
      ip2 = FactoryGirl.create(:inventory_pool, :name => 'Chemistry Lab')
      ip3 = FactoryGirl.create(:inventory_pool, :name => 'Film Studio')

      20.times do  
        us = FactoryGirl.create(:user)
        us.access_rights.build(:role => customer_role, :inventory_pool => ip1)
        us.access_rights.build(:role => customer_role, :inventory_pool => ip2)
        us.access_rights.build(:role => customer_role, :inventory_pool => ip3)
        us.save
      end


      binding.pry      

      puts "[END] Seeding the demo data"
    end
  end
end
