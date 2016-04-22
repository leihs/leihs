FactoryGirl.define do
  factory :supplier do
    name do
      Faker::Lorem.sentence
    end
  end
end
