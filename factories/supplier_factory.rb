FactoryGirl.define do
  factory :supplier do
    name do
      Faker::Lorem.words(rand(2..5)).join(' ')
    end
  end
end
