FactoryGirl.define do

  factory :user do
    login { Faker::Internet.user_name }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number.gsub(/\D/, "") }
    authentication_system { AuthenticationSystem.first.blank? ? FactoryGirl.create(:authentication_system) : AuthenticationSystem.first }
    unique_id { UUIDTools::UUID.random_create.to_s }
    email { Faker::Internet.email }
    badge_id { UUIDTools::UUID.random_create.to_s }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    zip { Faker::Address.zip_code }
    country { Faker::Address.country }
    language { Language.exists? ? Language.find_by_default(1) : LanguageFactory.create }
  end

end