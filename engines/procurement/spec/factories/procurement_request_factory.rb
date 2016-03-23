FactoryGirl.define do
  factory :procurement_request, class: Procurement::Request do
    user { FactoryGirl.create(:procurement_access, :requester).user }

    # association :budget_period, factory: :procurement_budget_period
    budget_period do
      Procurement::BudgetPeriod.current ||
                    FactoryGirl.create(:procurement_budget_period)
    end

    # association :group, factory: :procurement_group
    group { Procurement::Group.first || FactoryGirl.create(:procurement_group) }

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

  end
end
