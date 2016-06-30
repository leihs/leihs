FactoryGirl.define do
  factory :procurement_category_inspector, class: Procurement::CategoryInspector do
    association :user
    association :category, factory: :procurement_category
  end
end
