FactoryGirl.define do

  factory :inventory_pool do |i|
    name { Faker::Lorem.words(3).join.capitalize }
    description { Faker::Lorem.sentence }
    contact_details { Faker::Lorem.sentence }
    contract_description { name }
    email { Faker::Internet.email }
    contract_url { email }
    shortname { UUIDTools::UUID.random_create.to_s[0..5].upcase }
  end

end