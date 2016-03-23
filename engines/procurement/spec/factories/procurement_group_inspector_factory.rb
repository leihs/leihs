FactoryGirl.define do
  factory :procurement_group_inspector, class: Procurement::GroupInspector do
    association :user
    association :group, factory: :procurement_group
  end
end
