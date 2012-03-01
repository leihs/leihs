FactoryGirl.define do

  factory :item do
    inventory_code {"#{Faker::Lorem.words(3).join[0..2]}#{rand(1000...9999)}"}
    serial_number {"#{Faker::Lorem.words(3).join[0..2]}-#{rand(1000...9999)}#{Faker::Lorem.words(3).join[0..2]}#{rand(1000...9999)}"}
    model
    location
    supplier
    owner { inventory_pool }
    invoice_date { Time.local(  (Time.now.year - rand(5) - 1) , (rand(12) + 1), (rand(31)+1) ).to_date }
    price {rand(1.50...100).round(2)}
  end

end