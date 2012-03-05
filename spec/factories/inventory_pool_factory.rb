FactoryGirl.define do

  factory :inventory_pool do
    name { Faker::Lorem.words(3).join.capitalize }
    description { Faker::Lorem.sentence }
    contact_details { Faker::Lorem.sentence }
    contract_description { name }
    email { Faker::Internet.email }
    contract_url { email }
    shortname { name[0..2].to_s.upcase }
  end

end