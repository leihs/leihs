FactoryGirl.define do
  factory :procurement_category, class: Procurement::Category do
    name { Faker::Lorem.sentence }

    # association :main_category, factory: :procurement_main_category
    main_category { FactoryGirl.create(:procurement_main_category) }

    trait :with_templates do
      before :create do |category|
        category.main_category = FactoryGirl.create(:procurement_main_category)
      end
      after :create do |category|
        3.times do
          category.templates << FactoryGirl.create(:procurement_template)
        end
      end
    end
  end
end
