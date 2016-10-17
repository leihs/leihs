FactoryGirl.define do
  factory :procurement_budget_limit, class: Procurement::BudgetLimit do
    association :main_category, factory: :procurement_main_category
    association :budget_period, factory: :procurement_budget_period
    amount 1000
  end
end
