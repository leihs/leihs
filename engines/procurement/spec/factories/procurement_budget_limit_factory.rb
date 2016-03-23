FactoryGirl.define do
  factory :procurement_budget_limit, class: Procurement::BudgetLimit do
    association :group, factory: :procurement_group
    association :budget_period, factory: :procurement_budget_period
    amount 1000
  end
end
