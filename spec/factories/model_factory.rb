FactoryGirl.define do

  factory :model do
    name { Faker::Name.name }
    manufacturer { Faker::Name.name }
    description { Faker::Lorem.sentence }
    internal_description { Faker::Lorem.sentence }
    maintenance_period { rand(4) }
    is_package false
    technical_detail { Faker::Lorem.sentence }
    hand_over_note { Faker::Lorem.sentence }
  end

end