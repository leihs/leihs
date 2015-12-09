FactoryGirl.define do

  factory :accessory do
    model
    name { Faker::Name.name }
  end

end
