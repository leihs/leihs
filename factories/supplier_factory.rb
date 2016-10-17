FactoryGirl.define do
  factory :supplier do
    name do
      "#{Faker::Lorem.words(3).shuffle.join(' ')}_#{Faker::Lorem.characters(8)}"
    end
  end
end
