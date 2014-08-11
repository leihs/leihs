namespace :app do

  namespace :seed do


    def set_stupid_password_for(user)
      dba = DatabaseAuthentication.where(:login => user.login).first
      dba.password = 'password'
      dba.password_confirmation = 'password'
      dba.save
    end

    desc "Seed the app with data"
    task :demo => :environment do
      puts "[START] Seeding the demo data"
      require "factory_girl"
      require "faker"
#      require 'pry'
      #FactoryGirl.find_definitions

      ip1 = FactoryGirl.create(:inventory_pool, :name => 'General Reservation Desk')
      ip2 = FactoryGirl.create(:inventory_pool, :name => 'Chemistry Lab')
      ip3 = FactoryGirl.create(:inventory_pool, :name => 'Film Studio')

      # Some customers so that the database doesn't look so empty
      20.times do  
        us = FactoryGirl.create(:user)
        us.access_rights.build(:role => :customer, :inventory_pool => ip1)
        us.access_rights.build(:role => :customer, :inventory_pool => ip2)
        us.access_rights.build(:role => :customer, :inventory_pool => ip3)
        us.save
      end

      # A normal user that people can use to log in with
      normal_user = FactoryGirl.create(:user, :login => 'normal_user', :firstname => 'Normalio', :lastname => 'Normex')
      normal_user.access_rights.build(:role => :customer, :inventory_pool => ip1)
      normal_user.access_rights.build(:role => :customer, :inventory_pool => ip2)
      normal_user.access_rights.build(:role => :customer, :inventory_pool => ip3)
      normal_user.save
      set_stupid_password_for(normal_user)

      

      # An inventory manager
      manager_user = FactoryGirl.create(:user, :login => 'manager_user', :firstname => 'Inventory', :lastname => 'Manager')
      manager_user.access_rights.build(:role => :inventory_manager, :inventory_pool => ip1)
      manager_user.access_rights.build(:role => :inventory_manager, :inventory_pool => ip2)
      manager_user.access_rights.build(:role => :inventory_manager, :inventory_pool => ip3)
      manager_user.save
      set_stupid_password_for(manager_user)

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
      tt1 = FactoryGirl.create(:model, :product => 'Test tube, 20 cm', :manufacturer => 'ACME')
      tt1.categories << chem
      tt1.save


      tt2 = FactoryGirl.create(:model, :product => 'Test tube, 10 cm', :manufacturer => 'ACME')
      tt2.categories << chem
      tt2.save

      tt3 = FactoryGirl.create(:model, :product => 'Test tube, 5 cm', :manufacturer => 'ACME')
      tt3.categories << chem
      tt3.save

      bb = FactoryGirl.create(:model, :product => 'Bunsen burner', :manufacturer => 'ACME')
      bb.categories << chem
      bb.save
      
      cob = FactoryGirl.create(:model, :product => 'Chalice of blood', :manufacturer => 'ACME')
      cob.categories << chem
      cob.save

      # Inventory that is exlusive to the chemistry guys
      10.times do
        [tt1, tt2, tt3, bb, cob].each do |model|
          i = FactoryGirl.create(:item, :model => model, :owner => ip2, :inventory_pool => ip2)
        end
      end


      lc = FactoryGirl.create(:model, :product => 'Lighting case Arri Start-Up-Kit Fresnel', :manufacturer => 'Arri')
      lc.categories << lighting
      lc.save

      pb = FactoryGirl.create(:model, :product => 'Battery-powered light Photon Beard Hyperlight 471', :manufacturer => 'Photon Beard')
      pb.categories = [lighting, film]
      pb.save

      arri1 =  FactoryGirl.create(:model, :product => 'Arri Alexa PLUS DTE-SXS Super 35mm', :manufacturer => 'Arri')
      arri1.categories = [cams, film]
      arri1.save
      
      genelec = FactoryGirl.create(:model, :product => 'Genelec 8020B', :manufacturer => 'Genelec')
      genelec.categories << speakers
      genelec.save

      sony = FactoryGirl.create(:model, :product => 'HDCAM Sony HDW-750PC', :manufacturer => 'Sony')
      sony.categories << cams
      sony.save

      pana = FactoryGirl.create(:model, :product => 'Panasonic HDC-HS300', :manufacturer => 'Panasonic')
      pana.categories << cams
      pana.save

      manfrotto = FactoryGirl.create(:model, :product => 'Tripod Manfrotto Slide Leg Century A256SB', :manufacturer => 'Manfrotto')
      manfrotto.categories << tripods
      manfrotto.save

      acer = FactoryGirl.create(:model, :product => 'Acer H7531D Full-HD', :manufacturer => 'Acer')
      acer.categories << projectors
      acer.save

      sony_h = FactoryGirl.create(:model, :product => 'Headphones Sony MDR-V500', :manufacturer => 'Sony')
      sony_h.categories << head
      sony_h.save


      # General pool and film guys share some equipment that might work for both
      10.times do
        [pb, genelec, sony, pana, manfrotto, acer, sony_h].each do |model|
          i = FactoryGirl.create(:item, :model => model, :owner => ip1, :inventory_pool => ip1)
          i = FactoryGirl.create(:item, :model => model, :owner => ip3, :inventory_pool => ip3)
        end
      end

      10.times do
        [lc, arri1].each do |model|
          i = FactoryGirl.create(:item, :model => model, :owner => ip3, :inventory_pool => ip3)
        end
      end

      # Some items for those models


      puts "[END] Seeding the demo data"
    end
  end
end
