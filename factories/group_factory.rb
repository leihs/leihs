FactoryGirl.define do

  factory :group do
    name { Faker::Name.name }
    inventory_pool
  end
end
