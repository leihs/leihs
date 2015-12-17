FactoryGirl.define do

  trait :shared_item_license_attributes do
    sequence(:inventory_code) { |n| "#{Faker::Lorem.characters(20)}#{n}" }
    serial_number { 3.times.map { Faker::Internet.mac_address }.join('-') }
    owner do
      if InventoryPool.count > rand(3..10)
        InventoryPool.all.sample
      else
        FactoryGirl.create(:inventory_pool)
      end
    end
    inventory_pool { owner }

    after(:build) do |item|
      if item.properties?
        item.properties = item.properties.with_indifferent_access
      end
      if item.is_inventory_relevant
        item.properties[:anschaffungskategorie] ||= 'AV-Technik'
      end
    end
  end

  factory :item do
    shared_item_license_attributes

    model { FactoryGirl.create :model }
    location { FactoryGirl.create :location }
    supplier { FactoryGirl.create :supplier }
    invoice_date do
      Time.zone.local((Time.zone.now.year - rand(5) - 1),
                      (rand(12) + 1),
                      (rand(31) + 1)).to_date
    end
    price { rand(1500).round(2) }
    is_broken 0
    is_incomplete 0
    is_borrowable 1
    is_inventory_relevant 1
  end

  factory :license, class: :Item do
    shared_item_license_attributes

    model { FactoryGirl.create :software }
    properties do
      { license_type: 'single_workplace',
        activation_type: 'serial_number',
        operating_system: ['windows', 'linux'],
        installation: ['citrix', 'web'],
        procured_by: [true, false].sample ? User.all.sample.to_s : nil
                  }
    end
  end
end
