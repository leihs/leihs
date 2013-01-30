FactoryGirl.define do

  factory :role do
    name { Faker::Name.last_name }
  end
end
