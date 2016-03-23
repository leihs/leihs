FactoryGirl.define do
  factory :procurement_template, class: Procurement::Template do
    association :template_category, factory: :procurement_template_category
    article_name { Faker::Lorem.sentence }
    article_number { Faker::Number.number 6 }
    price { 1000 }
    supplier_name { Faker::Lorem.sentence }
  end
end
