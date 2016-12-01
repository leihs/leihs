FactoryGirl.define do
  factory :procurement_request, class: Procurement::Request do
    user { FactoryGirl.create(:procurement_access, :requester).user }

    # association :budget_period, factory: :procurement_budget_period
    budget_period do
      Procurement::BudgetPeriod.current ||
          FactoryGirl.create(:procurement_budget_period)
    end

    # association :category, factory: :procurement_category
    category do
      Procurement::Category.first ||
          FactoryGirl.create(:procurement_category)
    end

    article_name { Faker::Lorem.sentence }
    motivation { Faker::Lorem.sentence }
    price { 123 }
    requested_quantity { 5 }
    approved_quantity { nil }
    template { nil }
    priority { ['high', 'normal'].sample }

    before :create do |request|
      if request.template
        request.article_name = request.template.article_name
        request.article_number = request.template.article_number
        request.price = request.template.price
        request.supplier_name = request.template.supplier_name
      end
    end

    trait :full do
      organization do
        Procurement::Organization.first ||
          FactoryGirl.create(:procurement_organization, :with_parent)
      end

      model do
        Model.first || FactoryGirl.create(:model)
      end

      supplier do
        Supplier.first || FactoryGirl.create(:supplier)
      end

      location do
        Location.first || FactoryGirl.create(:location)
      end

      template do
        Procurement::Template.first || FactoryGirl.create(:procurement_template)
      end
      approved_quantity 5
      order_quantity 5
      price_currency 'CHF'
      replacement false
      supplier_name Faker::Company.name
      receiver Faker::Name.name
      location_name Faker::Address.street_name
      inspection_comment Faker::Lorem.sentence
      inspector_priority :medium
    end

  end
end
