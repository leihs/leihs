FactoryGirl.define do
  factory :procurement_access, class: Procurement::Access do
    association :user

    trait :requester do
      association :organization, factory: [:procurement_organization, :with_parent]
    end

    trait :admin do
      is_admin true
    end
  end
end
