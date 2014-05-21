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
  end

end
