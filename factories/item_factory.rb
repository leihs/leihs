FactoryGirl.define do

  trait :shared_item_license_attributes do
    inventory_code { "#{UUIDTools::UUID.random_create.to_s}" }
    serial_number { "#{Faker::Lorem.words(3).join.slice(0,3)}-#{rand(9999)+1000}#{Faker::Lorem.words(3).join.slice(0,2)}#{rand(9999)+1000}" }
    owner { FactoryGirl.create :inventory_pool }
    inventory_pool { owner }
  end

  factory :item do
    shared_item_license_attributes

    model { FactoryGirl.create :model }
    location { FactoryGirl.create :location }
    supplier { FactoryGirl.create :supplier }
    invoice_date { Time.local(  (Time.now.year - rand(5) - 1) , (rand(12) + 1), (rand(31)+1) ).to_date }
    price { rand(1500).round(2) }
    is_broken 0
    is_incomplete 0
    is_borrowable 1
    is_inventory_relevant 1
    properties { {anschaffungskategorie: "AV-Technik" } }
  end

  factory :license, class: :Item do
    shared_item_license_attributes

    model { FactoryGirl.create :software }
    properties { { license_type: "single_workspace",
                   activation_type: "serial_number",
                   operating_system: ["windows", "linux"],
                   installation: ["citrix", "web"] } }
  end
end
