# coding: UTF-8

# Persona:  Mike
# Job:      Inventory Manager
#

module Persona
  
  class Mike
    
    @@name = "Mike"
    @@lastname = "H."
    @@email = "mike@zhdk.ch"
    @@inventory_pool_names = ["A-Ausleihe", "IT-Ausleihe"]
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        create_inventory_manager_user
        create_location_and_building
        create_groups
        create_categories
        create_minimal_inventory
        create_accessories
        create_holidays
      end
    end
    
    def setup_dependencies 
      Persona.create :matti
    end
    
    def create_inventory_manager_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_names.first)
      @inventory_pool_2 = InventoryPool.find_by_name(@@inventory_pool_names.second)
      @user.access_rights.create(:role => :inventory_manager, :inventory_pool => @inventory_pool)
      @user.access_rights.create(:role => :inventory_manager, :inventory_pool => InventoryPool.last)
    end
    
    def create_location_and_building
      @building = FactoryGirl.create(:building, :name => "Ausstellungsstrasse 60", :code => "AU60")
      @location = FactoryGirl.create(:location, :room => "UG 13", :shelf => "Ausgabe", :building => @building)
    end
    
    def create_groups
      @group_cast = FactoryGirl.create(:group, :name => "Cast", :inventory_pool => @inventory_pool)
      @group_iad = FactoryGirl.create(:group, :name => "IAD", :inventory_pool => @inventory_pool)
      @group_wu = FactoryGirl.create(:group, :name => "Wu", :inventory_pool => @inventory_pool)
    end

    def create_categories
      @beamer_category = FactoryGirl.create(:category, :name => "Beamer")
      @beamer_category.images << FactoryGirl.create(:image, target: @beamer_category)
      @camera_category = FactoryGirl.create(:category, :name => "Kameras")
      @tripod_category = FactoryGirl.create(:category, :name => "Stative")
      @hifi_category = FactoryGirl.create(:category, :name => "Hifi-Anlagen")
      @notebook_category = FactoryGirl.create(:category, :name => "Notebooks")
      @helicopter_category = FactoryGirl.create(:category, :name => "RC Helikopter")
      @computer_category = FactoryGirl.create(:category, :name => "Computer")

      @short_distance_subcategory = FactoryGirl.create :category, name: "Kurzdistanz"
      @portable_subcategory = FactoryGirl.create :category, name: "Portabel"
      @standard_subcategory = FactoryGirl.create :category, name: "Standard"
      @micro_subcategory = FactoryGirl.create :category, name: "Micro"

      @camera_category.children << @standard_subcategory
      @camera_category.children << @short_distance_subcategory
      @notebook_category.children << @standard_subcategory
      @notebook_category.children << @portable_subcategory
      @beamer_category.children << @portable_subcategory
      @portable_subcategory.children << @micro_subcategory
    end

    def create_minimal_inventory
      
      setup_sharp_beamers
      setup_ultra_compact_beamers
      setup_micro_beamers
      setup_more_beamers
      setup_cameras
      setup_more_cameras
      
      setup_hifis
      setup_tripods
      setup_headphones
      setup_options
      
      setup_templates
      setup_packages
      
      setup_not_borrowable
      setup_retired
      setup_broken
      setup_incomplete
      setup_problematic
      setup_deletable_model
      
      setup_inventory_moved_to_other_responsible
      setup_inventory_for_group_cast

      setup_software
      setup_models_without_version
    end
    
    def create_accessories
      Model.all.each do |model|
        rand(1..5).times do
          accessory = FactoryGirl.create :accessory, :model => model
          @inventory_pool.accessories << accessory if rand() > 0.5
        end
      end
    end

    def setup_sharp_beamers
      @beamer_model = FactoryGirl.create(:model, :product => "Sharp Beamer", :version => "123",
                                :manufacturer => "Sharp", 
                                :description => "Beamer, geeignet für alle Verwendungszwecke.", 
                                :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                                :maintenance_period => 0)
      @beamer_model.model_links.create :model_group => @beamer_category
      @beamer_model.model_links.create :model_group => @portable_subcategory

      @beamer_model2 = FactoryGirl.create(:model, :product => "Sharp Beamer 2D",
                                          :manufacturer => "Sharp", 
                                          :description => "Beamer, geeignet für alle Verwendungszwecke.", 
                                          :maintenance_period => 0)
      @beamer_model2.model_links.create :model_group => @beamer_category

      @beamer_model3 = FactoryGirl.create(:model, :product => "Mini Beamer",
                                          :manufacturer => "Panasonic", 
                                          :description => "Beamer, geeignet für alle Verwendungszwecke.", 
                                          :maintenance_period => 0)
      @beamer_model3.model_links.create :model_group => @beamer_category

      @beamer_model4 = FactoryGirl.create(:model, :product => "Sharp Beamer", :version => "456",
                                          :manufacturer => "Sharp", 
                                          :description => "Beamer, geeignet für alle Verwendungszwecke.", 
                                          :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                                          :maintenance_period => 0)

      @beamer_item = FactoryGirl.create(:item, :inventory_code => "beam123", :serial_number => "xyz456", name: "name123", :model => @beamer_model, :location => @location, :owner => @inventory_pool)
      @beamer_item2 = FactoryGirl.create(:item, :inventory_code => "beam345", :serial_number => "xyz890", :model => @beamer_model, :location => @location, :owner => @inventory_pool)
      @beamer_item3 = FactoryGirl.create(:item, :inventory_code => "beam678", :serial_number => "xyz678", :model => @beamer_model2, :location => @location, :owner => @inventory_pool)
      @beamer_item4 = FactoryGirl.create(:item, :inventory_code => "beam749", :serial_number => "xyz749", :model => @beamer_model, :location => @location, :owner => @inventory_pool, inventory_pool: @inventory_pool_2)
      @beamer_item5 = FactoryGirl.create(:item, :inventory_code => "beamTest123", :serial_number => "xyz749", :model => @beamer_model4, :location => @location, :owner => @inventory_pool, inventory_pool: @inventory_pool)
    end

    def setup_more_beamers
      (1..20).to_a.each do |i|
        model = FactoryGirl.create(:model, :product => "Beamer #{i} #{Faker::Lorem.word}",
                           :manufacturer => "Sony", 
                           :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                           :maintenance_period => 0)
        model.model_links.create :model_group => @beamer_category
        FactoryGirl.create(:item, :inventory_code => "mbeam#{i}", :serial_number => "mbeam#{i}", name: "mbeam#{i}", :model => model, :location => @location, :owner => @inventory_pool)
      end
    end

    def setup_ultra_compact_beamers
      @ultra_compact_beamer = FactoryGirl.create(:model, :product => "Ultra Compact Beamer",
                                :manufacturer => "Sony", 
                                :description => "Besonders kleiner Beamer.", 
                                :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                                :maintenance_period => 0)
      @ultra_compact_beamer.model_links.create :model_group => @beamer_category
      @ultra_compact_beamer.model_links.create :model_group => @portable_subcategory
      @ultra_compact_beamer_item = FactoryGirl.create(:item, :inventory_code => "ucbeam1", :serial_number => "minbeam1", name: "ucbeam1", :model => @ultra_compact_beamer, :location => @location, :owner => @inventory_pool)
    end

    def setup_micro_beamers
      @micro_beamer = FactoryGirl.create(:model, :product => "Micro Beamer",
                                :manufacturer => "Micro", 
                                :description => "Besonders mikro kleiner Beamer.", 
                                :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                                :maintenance_period => 0)
      @micro_beamer.model_links.create :model_group => @micro_subcategory
      @micro_beamer_item = FactoryGirl.create(:item, :inventory_code => "microbeam1", :serial_number => "microbeam1", name: "microbeam1", :model => @micro_beamer, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_cameras
      @camera_model = FactoryGirl.create(:model, :product => "Kamera Nikon", :version => "X12",
                                :manufacturer => "Nikon", 
                                :description => "Super Kamera.", 
                                :hand_over_note => "Kamera brauch Akkus!", 
                                :maintenance_period => 0)
      @camera_model.model_links.create :model_group => @camera_category
      @camera_item = FactoryGirl.create(:item, :inventory_code => "cam123", :serial_number => "abc234", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item2= FactoryGirl.create(:item, :inventory_code => "cam345", :serial_number => "ab567", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item3= FactoryGirl.create(:item, :inventory_code => "cam567", :serial_number => "ab789", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item4= FactoryGirl.create(:item, :inventory_code => "cam53267", :serial_number => "ab782129", :model => @camera_model, :location => @location, :owner => @inventory_pool)
      @camera_item5= FactoryGirl.create(:item, :inventory_code => "cam532asd67", :serial_number => "ab78as2129", :model => @camera_model, :location => @location, :owner => @inventory_pool)
    end

    def setup_more_cameras
      (1..30).to_a.each do |i|
        model = FactoryGirl.create(:model, :product => "Camera #{i} #{Faker::Lorem.word}",
                                   :manufacturer => "Nikon",
                                   :maintenance_period => 0)
        model.model_links.create :model_group => @camera_category
        FactoryGirl.create(:item, :inventory_code => "mcam#{i}", :serial_number => "mcam#{i}", name: "mcam#{i}", :model => model, :location => @location, :owner => @inventory_pool)
      end
    end

    def setup_tripods
      @tripod_model = FactoryGirl.create(:model, :product => "Kamera Stativ", :version => "123",
                                :manufacturer => "Feli", 
                                :description => "Stabiles Kamera Stativ", 
                                :hand_over_note => "Stativ muss mit Stativtasche ausgehändigt werden.",
                                :maintenance_period => 0)
      @tripod_model.model_links.create :model_group => @tripod_category
      @tripod_item = FactoryGirl.create(:item, :inventory_code => "tri789", :serial_number => "fgh567", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
      @tripod_item2 = FactoryGirl.create(:item, :inventory_code => "tri123", :serial_number => "fgh987", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
      @tripod_item3 = FactoryGirl.create(:item, :inventory_code => "tri923", :serial_number => "asd213", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
      @tripod_item4 = FactoryGirl.create(:item, :inventory_code => "tri212", :serial_number => "tri212", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_hifis
      @hifi_model = FactoryGirl.create(:model, :product => "Hifi Standard", :manufacturer => "Sony")
      @hifi_model.model_links.create :model_group => @hifi_category
      @hifi_item = FactoryGirl.create(:item, :inventory_code => "hifi123", :serial_number => "hifi123", :model => @hifi_model, :location => @location, :owner => @inventory_pool)
      @hifi_model.partitions << Partition.create(model_id: @hifi_model.id,
                                                 inventory_pool_id: @inventory_pool.id,
                                                 group_id: Group.create(name: "Group Hifi", inventory_pool_id: @inventory_pool.id).id,
                                                 quantity: 1)
    end

    def setup_headphones
      manufacturer = "Bose"
      @model_with_retired_item = FactoryGirl.create(:model, :product => manufacturer + Faker::Commerce.product_name,
                                                    :manufacturer => manufacturer, 
                                                    :description => Faker::Lorem.paragraph, 
                                                    :maintenance_period => 0)

      extra_model = FactoryGirl.create(:model, :product => manufacturer + Faker::Commerce.product_name,
                                       :manufacturer => manufacturer,
                                       :description => Faker::Lorem.paragraph, 
                                       :maintenance_period => 0)
      FactoryGirl.create(:item, :inventory_code => Faker::Lorem.characters(6), :serial_number => Faker::Lorem.characters(6), :model => extra_model, :location => @location, :owner => @inventory_pool)
    end

    def setup_options
      @akku_aa = FactoryGirl.create(:option, :product => "Akku AA",
                                             :inventory_pool => @inventory_pool,
                                             :inventory_code => "akku-aa")      
      @akku_aaa = FactoryGirl.create(:option, :product => "Akku AAA",
                                             :inventory_pool => @inventory_pool,
                                             :inventory_code => "akku-aaa")      
      @usb_cable = FactoryGirl.create(:option, :product => "USB Kabel",
                                             :inventory_pool => @inventory_pool,
                                             :inventory_code => "usb")      
    end
    
    def setup_templates
      @camera_tripod_template = FactoryGirl.build(:template, :name => "Kamera & Stativ")
      @camera_tripod_template.model_links << FactoryGirl.build(:model_link, :model_group => @camera_tripod_template, :model => @camera_model, :quantity => 1)
      @camera_tripod_template.model_links << FactoryGirl.build(:model_link, :model_group => @camera_tripod_template, :model => @tripod_model, :quantity => 1)
      @camera_tripod_template.inventory_pools << @inventory_pool
      @camera_tripod_template.save

      @beamer_hifi_template = FactoryGirl.build(:template, :name => "Beamer & Hifi")
      @beamer_hifi_template.model_links << FactoryGirl.build(:model_link, :model_group => @camera_tripod_template, :model => @beamer_model, :quantity => 1)
      @beamer_hifi_template.model_links << FactoryGirl.build(:model_link, :model_group => @camera_tripod_template, :model => @hifi_model, :quantity => 1)
      @beamer_hifi_template.inventory_pools << @inventory_pool
      @beamer_hifi_template.save

      @unaccomplishable_template = FactoryGirl.build(:template, :name => "Unaccomplishable template")
      @unaccomplishable_template.model_links << FactoryGirl.build(:model_link, :model_group => @unaccomplishable_template, :model => @camera_model, :quantity => 999)
      @unaccomplishable_template.model_links << FactoryGirl.build(:model_link, :model_group => @unaccomplishable_template, :model => @tripod_model, :quantity => 999)
      @unaccomplishable_template.inventory_pools << @inventory_pool
      @unaccomplishable_template.save
    end

    def setup_packages
      @camera_package = FactoryGirl.create(:package_model_with_items, :inventory_pool => @inventory_pool, :product => "Kamera Set")
      @camera_package2 = FactoryGirl.create(:package_model_with_items, :inventory_pool => @inventory_pool, :product => "Kamera Set2")

      # create packages in multiple inventory_pools related to the same model
      @camera_package.items << FactoryGirl.create(:package_item_with_parts, owner: @inventory_pool_2, inventory_pool: @inventory_pool_2)
    end
    
    def setup_not_borrowable
      # canon
      @canon_d5 = FactoryGirl.create(:model, :product => "Kamera Canon D5",
                                :manufacturer => "Canon", 
                                :description => "Ganz teure Kamera", 
                                :hand_over_note => "Kamera brauch Akkus!", 
                                :maintenance_period => 0)
      @canon_d5.model_links.create :model_group => @camera_category
      @canon_d5_item = FactoryGirl.create(:item, :inventory_code => "cand5", :is_borrowable => false, :serial_number => "cand5", :model => @camera_model, :location => @location, :owner => @inventory_pool)

      # beamer
      @not_borrowable_beamer = FactoryGirl.create(:item, :inventory_code => "beam21231", :is_borrowable => false, :serial_number => "beamas12312", :model => @beamer_model, :location => @location, :owner => @inventory_pool)

      @not_borrowable_hifi = FactoryGirl.create(:item, :inventory_code => "hifi345", :is_borrowable => false, :serial_number => "hifi345", :model => @hifi_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_broken
      @windows_laptop_model = FactoryGirl.create(:model, :product => "Windows Laptop",
                                :manufacturer => "Microsoft", 
                                :description => "Ein Laptop der Marke Microsoft", 
                                :hand_over_note => "Laptop mit Tasche ausgeben", 
                                :maintenance_period => 0)
      @windows_laptop_model.model_links.create :model_group => @notebook_category
      @windows_laptop_item = FactoryGirl.create(:item, :inventory_code => "wlaptop1", :is_broken => true, :serial_number => "wlaptop1", :model => @windows_laptop_model, :location => @location, :owner => @inventory_pool)
    end

    def setup_incomplete
      @helicopter_model = FactoryGirl.create(:model, :product => "Walkera v120", :version => "1G",
                                :manufacturer => "Walkera", 
                                :description => "3D Helikopter", 
                                :maintenance_period => 0)
      @helicopter_model.model_links.create :model_group => @helicopter_category
      @helicopter_item = FactoryGirl.create(:item, :inventory_code => "v120d02", :is_incomplete => true, :serial_number => "v120d02", :model => @helicopter_model, :location => @location, :owner => @inventory_pool)
      @helicopter_model.properties << Property.create(:key => "Rotorduchmesser", :value => "120")
      @helicopter_model.properties << Property.create(:key => "Akkus", :value => "2")
      @helicopter_model.properties << Property.create(:key => "Farbe", :value => "Rot")
      @helicopter_model.compatibles << @windows_laptop_model
    end

    def setup_problematic
      FactoryGirl.create(:item, model: @helicopter_model, owner: @inventory_pool, retired: Date.today, retired_reason: Faker::Lorem.sentence, is_broken: true, is_incomplete: true, is_borrowable: false)
    end

    def setup_deletable_model
      @helicopter_model2 = FactoryGirl.create(:model, :product => "Walkera v120", :version => "2G",
                                :manufacturer => "Walkera", 
                                :description => "3D Helikopter", 
                                :maintenance_period => 0)
      @helicopter_item2 = FactoryGirl.create(:item, :inventory_code => "v120d022g", :serial_number => "v120d022g", :model => @helicopter_model2, :location => @location, :owner => @inventory_pool)
      @helicopter_item2_2 = FactoryGirl.create(:item, :inventory_code => "v120d022g2", :serial_number => "v120d022g2", :model => @helicopter_model2, :location => @location, :owner => @inventory_pool)
      @helicopter_model2.partitions << Partition.create(model_id: @helicopter_model.id, 
                                                      inventory_pool_id: @inventory_pool.id, 
                                                      group_id: Group.create(name: "Group A", inventory_pool_id: @inventory_pool.id).id,
                                                      quantity: 1)
      @helicopter_model2.attachments << FactoryGirl.create(:attachment)
      @helicopter_model2.images << FactoryGirl.create(:image, target: @helicopter_model2)
      @helicopter_model2.images << FactoryGirl.create(:image, :another, target: @helicopter_model2)
      @helicopter_model2.model_links.create :model_group => @helicopter_category
      @helicopter_model2.properties << Property.create(:key => "Rotorduchmesser", :value => "120")
      @helicopter_model2.properties << Property.create(:key => "Akkus", :value => "2")
      @helicopter_model2.properties << Property.create(:key => "Farbe", :value => "Rot")
      @helicopter_model2.properties << Property.create(:key => "max. Speed", :value => "80 kmh")
      @helicopter_model2.properties << Property.create(:key => "Gyro", :value => "Ja")
      @helicopter_model2.properties << Property.create(:key => "Achsen", :value => "3-Achsen")
      @helicopter_model2.compatibles << @windows_laptop_model

      @helicopter_model3 = FactoryGirl.create(:model, :product => "Walkera v120", :version => "3G",
                                :manufacturer => "Walkera", 
                                :description => "3D Helikopter", 
                                :maintenance_period => 0)
      @helicopter_model3.partitions << Partition.create(model_id: @helicopter_model.id, 
                                                      inventory_pool_id: @inventory_pool.id, 
                                                      group_id: Group.create(name: "Group B", inventory_pool_id: @inventory_pool.id).id,
                                                      quantity: 5)
      @helicopter_model3.attachments << FactoryGirl.create(:attachment)
      @helicopter_model3.images << FactoryGirl.create(:image, target: @helicopter_model3)
      @helicopter_model3.model_links.create :model_group => @helicopter_category
      @helicopter_model3.properties << Property.create(:key => "Rotorduchmesser", :value => "120")
      @helicopter_model3.properties << Property.create(:key => "Akkus", :value => "2")
      @helicopter_model3.properties << Property.create(:key => "Farbe", :value => "Rot")
      @helicopter_model3.compatibles << @windows_laptop_model
    end

    def setup_retired
      @iMac = FactoryGirl.create(:model, :product => "iMac",
                                :manufacturer => "Apple", 
                                :description => "Apples alter iMac", 
                                :maintenance_period => 0)
      @iMac.model_links.create :model_group => @computer_category
      FactoryGirl.create(:item, :inventory_code => "iMac1", :retired => Date.today, :retired_reason => "This Item is gone", :is_borrowable => true, :serial_number => "iMac5", :model => @iMac, :location => @location, :owner => @inventory_pool)
      FactoryGirl.create(:item, :inventory_code => "iMac2", :retired => Date.today, :retired_reason => "This Item is gone", :is_borrowable => true, :serial_number => "iMac6", :model => @iMac, :location => @location, :inventory_pool => @inventory_pool, :owner => InventoryPool.find {|ip| not @@inventory_pool_names.include?(ip.name)})

      FactoryGirl.create(:item, :inventory_code => Faker::Lorem.characters(6), :retired => Date.today, :retired_reason => "This Item is gone", :is_borrowable => true, :serial_number => Faker::Lorem.characters(6), :model => @model_with_retired_item, :location => @location, :owner => @inventory_pool)
      FactoryGirl.create(:item, :inventory_code => Faker::Lorem.characters(6), :is_borrowable => true, :serial_number => Faker::Lorem.characters(6), :model => @model_with_retired_item, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_inventory_moved_to_other_responsible
      @beamer_for_it = FactoryGirl.create(:item, :inventory_code => "beam897", :inventory_pool_id => InventoryPool.find_by_name("IT-Ausleihe").id, :serial_number => "xyz890", :model => @beamer_model, :location => @location, :owner => @inventory_pool)    
      @beamer_for_it2 = FactoryGirl.create(:item, :inventory_code => "minibeam12", :inventory_pool_id => InventoryPool.find_by_name("IT-Ausleihe").id, :serial_number => "xyz890", :model => @beamer_model3, :location => @location, :owner => @inventory_pool)    
      @beamer_for_av = FactoryGirl.create(:item, :inventory_code => "minibeam34", :inventory_pool_id => InventoryPool.find_by_name("AV-Technik").id, :serial_number => "xyz890", :model => @beamer_model3, :location => @location, :owner => @inventory_pool)    
    end

    def setup_inventory_for_group_cast
      Partition.create({:model => @helicopter_model, :inventory_pool => @inventory_pool, :group => @group_cast, :quantity => 1})
      Partition.create({:model => @camera_model, :inventory_pool => @inventory_pool, :group => @group_cast, :quantity => 1})
      Partition.create({:model => @camera_model, :inventory_pool => @inventory_pool, :group => @group_iad, :quantity => 1})
    end

    def create_holidays
      (0..1).each do |n|
        christmas = Date.new(Date.today.year + n, 12, 24)
        @inventory_pool.holidays.create(start_date: christmas, end_date: christmas + 2.days, name: "Christmas")
      end
    end

    def setup_software
      rand(2..6).times { FactoryGirl.create :license, owner: @inventory_pool, is_borrowable: [true, false].sample }
      FactoryGirl.create :license, owner: @inventory_pool, inventory_pool: @inventory_pool_2, is_borrowable: [true, false].sample
      FactoryGirl.create :license, owner: @inventory_pool, retired: Date.today, retired_reason: Faker::Lorem.sentence, is_borrowable: [true, false].sample
      FactoryGirl.create :license, owner: @inventory_pool_2, inventory_pool: @inventory_pool, retired: Date.today, retired_reason: Faker::Lorem.sentence, is_borrowable: [true, false].sample
      FactoryGirl.create :license, owner: @inventory_pool_2, is_borrowable: true
      FactoryGirl.create :license, owner: @inventory_pool, invoice_date: Date.today, properties: { license_expiration: Date.today.to_s, maintenance_contract: true.to_s, maintenance_expiration: Date.today.to_s }

      software = FactoryGirl.create :software, technical_detail: "test http://test.ch\r\nwww.foo.ch\r\njust a text"
      rand(1..3).times { software.attachments << FactoryGirl.create(:attachment) }
      FactoryGirl.create :license,
        owner: @inventory_pool,
        model: software,
        properties: { quantity_allocations: [{room: Faker::Lorem.word, quantity: rand(1..50)},
                                             {room: Faker::Lorem.word, quantity: rand(1..50)}]}

      software = FactoryGirl.create :software, technical_detail: "test http://test.ch\r\nwww.foo.ch\r\njust a text"
      rand(1..3).times { software.attachments << FactoryGirl.create(:attachment) }

      FactoryGirl.create :license,
        owner: @inventory_pool,
        properties: { operating_system: ["windows","linux", "mac_os_x"][0..rand(0..2)],
                      license_type: ["concurrent", "site_license", "multiple_workplace"].sample,
                      total_quantity: rand(300),
                      quantity_allocations: [{room: Faker::Lorem.word, quantity: rand(1..50)},
                                             {room: Faker::Lorem.word, quantity: rand(1..50)}]}
    end

    def setup_models_without_version
      FactoryGirl.create :model, version: nil
    end
  end
end
