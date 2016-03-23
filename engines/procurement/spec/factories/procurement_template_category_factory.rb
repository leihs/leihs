FactoryGirl.define do
  factory :procurement_template_category, class: Procurement::TemplateCategory do
    association :group, factory: :procurement_group
    name { Faker::Lorem.sentence }

    trait :with_templates do
      after :create do |category|
        3.times do
          category.templates << FactoryGirl.create(:procurement_template)
        end
      end
    end
  end
end
