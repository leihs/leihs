FactoryGirl.define do
  factory :procurement_organization, class: Procurement::Organization do
    name { Faker::Company.name }
    shortname { Faker::Company.suffix }

    trait :with_parent do
      association :parent, factory: :procurement_organization
    end
  end
end
