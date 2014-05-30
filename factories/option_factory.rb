FactoryGirl.define do

  factory :option do
    inventory_pool { FactoryGirl.create :inventory_pool }
    inventory_code { "#{Faker::Lorem.words(3).join.slice(0,3)}#{rand(9999)+1000}" }
    manufacturer { nil }
    product { Faker::Commerce.product_name }
    version
    price { rand(1500).round(2) }    
  end
end
