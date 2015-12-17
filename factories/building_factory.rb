FactoryGirl.define do

  factory :building do
    name { Faker::Lorem.words(3).join.capitalize }
    code { Faker::Lorem.words(3).join[0..2] }
  end

end
