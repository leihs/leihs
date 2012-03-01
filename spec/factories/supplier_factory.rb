FactoryGirl.define do

  factory :supplier do
    name {Faker::Lorem.words(3).join}
  end

end