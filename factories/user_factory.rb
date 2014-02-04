FactoryGirl.define do

  factory :user do
    login { [Faker::Internet.user_name, "123"].join('_') } # make sure the login has at least 3 chars
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number.gsub(/\D/, "") }
    authentication_system { AuthenticationSystem.first.blank? ? FactoryGirl.create(:authentication_system) : AuthenticationSystem.first }
    unique_id { UUIDTools::UUID.random_create.to_s }
    email { Faker::Internet.email }
    badge_id { UUIDTools::UUID.random_create.to_s }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    country { Faker::Address.country }
    zip { "#{country[0]}-#{Faker::Address.zip_code}".squish }
    language { Language.find_by_default(true) || LanguageFactory.create }
    delegator_user { nil }

    after(:create) do |user|
      unless user.is_delegation
        FactoryGirl.create(:database_authentication, :user => user, :password => "password")
      end
    end
  end

end
