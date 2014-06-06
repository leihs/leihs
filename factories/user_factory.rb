FactoryGirl.define do

  factory :user do
    login { [Faker::Internet.user_name, (100..9999).to_a.sample].join('_') } # make sure the login has at least 3 chars
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number.gsub(/\D/, "") }
    authentication_system { AuthenticationSystem.first.blank? ? FactoryGirl.create(:authentication_system) : AuthenticationSystem.first }
    unique_id { Faker::Lorem.characters(18) }
    email {
      existing_emails = User.pluck :email
      begin
        r = Faker::Internet.email
      end while existing_emails.include? r
      r
    }
    badge_id { Faker::Lorem.characters(18) }
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
