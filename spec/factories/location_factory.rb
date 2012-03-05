FactoryGirl.define do

  factory :location do
    room { Faker::Lorem.words(2).join.capitalize }
    shelf { Faker::Lorem.words(2).join }
    building { Factory :building }
  end

end