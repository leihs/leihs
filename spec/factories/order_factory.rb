FactoryGirl.define do

  factory :order do
    user { Factory :user }
    inventory_pool { Factory :inventory_pool }
    status_const 1
    purpose { Faker::Lorem.sentence }
  end
end