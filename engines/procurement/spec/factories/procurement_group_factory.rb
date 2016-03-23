FactoryGirl.define do
  factory :procurement_group, class: Procurement::Group do
    name { Faker::Lorem.words(2).join(' ') }
    email { Faker::Internet.email }
  end
end
