namespace :app do

  namespace :seed do

    desc "Seed the app with data"
    task :demo => :environment do
      puts "[START] Seeding the demo data"
      require "factory_girl"
      require "faker"
      require 'pry'
      #FactoryGirl.find_definitions

      customer_role = Role.where(:name => 'customer').first
      admin_role = Role.where(:name => 'admin').first
      manager_role = Role.where(:name => 'manager').first
      
      ip1 = FactoryGirl.create(:inventory_pool, :name => 'General Reservation Desk')
      ip2 = FactoryGirl.create(:inventory_pool, :name => 'Chemistry Lab')
      ip3 = FactoryGirl.create(:inventory_pool, :name => 'Film Studio')

      # Some customers so that the database doesn't look so empty
      20.times do  
        us = FactoryGirl.create(:user)
        us.access_rights.build(:role => customer_role, :inventory_pool => ip1)
        us.access_rights.build(:role => customer_role, :inventory_pool => ip2)
        us.access_rights.build(:role => customer_role, :inventory_pool => ip3)
        us.save
      end

      # A normal user that people can use to log in with
      normal_user_1 = FactoryGirl.create(:user, :login => 'normal_user_1', :firstname => 'Normalio', :lastname => 'Normex')
      normal_user_1.access_rights.build(:role => customer_role, :inventory_pool => ip1)
      normal_user_1.access_rights.build(:role => customer_role, :inventory_pool => ip2)
      normal_user_1.access_rights.build(:role => customer_role, :inventory_pool => ip3)
      normal_user_1.save
      FactoryGirl.create(:database_authentication, :user => normal_user_1, :password => 'pass')
      

      # An inventory manager
      manager_user_1 = FactoryGirl.create(:user, :login => 'manager_user_1', :firstname => 'Inventory', :lastname => 'Manager')
      manager_user_1.access_rights.build(:role => manager_role, :inventory_pool => ip1, :access_level => 3)
      manager_user_1.access_rights.build(:role => manager_role, :inventory_pool => ip2, :access_level => 3)
      manager_user_1.access_rights.build(:role => manager_role, :inventory_pool => ip3, :access_level => 3)   
      manager_user_1.save
      FactoryGirl.create(:database_authentication, :user => manager_user_1, :password => 'pass')

      # Categories
      head = FactoryGirl.create(:category, :name => 'Headphones')
      speakers = FactoryGirl.create(:category, :name => 'Speakers')
      chem = FactoryGirl.create(:category, :name => 'Chemistry Equipment')
      film = FactoryGirl.create(:category, :name => 'Film and Video')
      projectors = FactoryGirl.create(:category, :name => 'Projectors')

      lighting = FactoryGirl.create(:category, :name => 'Lighting')
      lighting.parents << film
      lighting.save

      cams = FactoryGirl.create(:category, :name => 'Cameras')
      cams.parents << film
      cams.save

      tripods = FactoryGirl.create(:category, :name => 'Tripods')
      tripods.parents << film
      tripods.save

      head.parents << film
      head.save

      # Models and items
      tt1 = FactoryGirl.create(:model, :name => 'Test tube, 20 cm', :manufacturer => 'ACME')
      tt1.categories << chem
      tt1.save
      10.times do
        i = FactoryGirl.create(:item, :model => tt1, :owner => ip2, :inventory_pool => ip2)
      end

      tt2 = FactoryGirl.create(:model, :name => 'Test tube, 10 cm', :manufacturer => 'ACME')
      tt2.categories << chem
      tt2.save

      tt3 = FactoryGirl.create(:model, :name => 'Test tube, 5 cm', :manufacturer => 'ACME')
      tt3.categories << chem
      tt3.save

      bb = FactoryGirl.create(:model, :name => 'Bunsen burner', :manufacturer => 'ACME')
      bb.categories << chem
      bb.save
      
      cob = FactoryGirl.create(:model, :name => 'Chalice of blood', :manufacturer => 'ACME')
      cob.categories << chem
      cob.save

      lc = FactoryGirl.create(:model, :name => 'Lighting case Arri Start-Up-Kit Fresnel', :manufacturer => 'Arri')
      lc.categories << lighting
      lc.save

      pb = FactoryGirl.create(:model, :name => 'Battery-powered light Photon Beard Hyperlight 471', :manufacturer => 'Photon Beard')
      pb.categories = [lighting, film]
      pb.save

      arri1 =  FactoryGirl.create(:model, :name => 'Arri Alexa PLUS DTE-SXS Super 35mm', :manufacturer => 'Arri')
      arri1.categories = [cams, film]
      arri1.save
      
      genelec = FactoryGirl.create(:model, :name => 'Genelec 8020B', :manufacturer => 'Genelec')
      genelec.categories << speakers
      genelec.save

      sony = FactoryGirl.create(:model, :name => 'HDCAM Sony HDW-750PC', :manufacturer => 'Sony')
      sony.categories << cams
      sony.save

      pana = FactoryGirl.create(:model, :name => 'Panasonic HDC-HS300', :manufacturer => 'Panasonic')
      pana.categories << cams
      pana.save

      manfrotto = FactoryGirl.create(:model, :name => 'Tripod Manfrotto Slide Leg Century A256SB', :manufacturer => 'Manfrotto')
      manfrotto.categories << tripods
      manfrotto.save

      acer = FactoryGirl.create(:model, :name => 'Acer H7531D Full-HD', :manufacturer => 'Acer')
      acer.categories << projectors
      acer.save

      sony_h = FactoryGirl.create(:model, :name => 'Headphones Sony MDR-V500', :manufacturer => 'Sony')
      sony_h.categories << head
      sony_h.save


      # Some items for those models


      puts "[END] Seeding the demo data"
    end
  end
end
