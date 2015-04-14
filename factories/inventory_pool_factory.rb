FactoryGirl.define do

  factory :inventory_pool do |i|
    name { Faker::Lorem.words(4).join.capitalize }
    description { Faker::Lorem.sentence }
    contact_details { Faker::Lorem.sentence }
    contract_description { name }
    email { Faker::Internet.email }
    contract_url { email }
    shortname { Faker::Lorem.characters(6).upcase }
    automatic_suspension { false }

    factory :inventory_pool_with_customers do
      after(:create) do |inventory_pool, evaluator|
        rand(3..6).times do
          user = FactoryGirl.create :user
          user.access_rights.create(inventory_pool: inventory_pool, role: :customer)
        end
      end
    end
  end

end
