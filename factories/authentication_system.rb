FactoryGirl.define do

  factory :authentication_system do
    name Faker::Lorem.words(1).join.capitalize
    class_name { name }
    is_default { AuthenticationSystem.find_by_is_default(1).blank? ? 1 : 0 }
    is_active 1
  end
end
