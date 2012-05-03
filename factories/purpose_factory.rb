FactoryGirl.define do

  factory :purpose do
    description { Faker::Lorem.sentences 2 }
  end
  
end