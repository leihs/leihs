FactoryGirl.define do
  factory :supplier do
    name do
      Faker::Lorem.words(3).shuffle.join(' ')
    end
  end
end
