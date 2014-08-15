FactoryGirl.define do

  factory :supplier do
    name { Faker::Lorem.words(4).join }
  end

end