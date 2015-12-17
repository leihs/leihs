FactoryGirl.define do

  factory :database_authentication do
    user { FactoryGirl.create(:user) }
    password { Faker::Lorem.words(2).join }
    password_confirmation { password }
    login { user.login }
  end

end
