FactoryGirl.define do

  factory :category do
    name Faker::Lorem.words(3).join.capitalize
  end

end
