FactoryGirl.define do

  factory :database_authentication do
    user { Factory(:user) }
    password Faker::Lorem.words(2).join
    password_confirmation { password }
    login { user.email }
  end

end