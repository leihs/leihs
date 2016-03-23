FactoryGirl.define do
  factory :procurement_budget_period, class: Procurement::BudgetPeriod do
    name { Faker::Lorem.words(2).join(' ') }

    inspection_start_date do
      last_budget_period = Procurement::BudgetPeriod.order(:end_date).last
      if last_budget_period
        last_budget_period.end_date + 1.month
      else
        Time.zone.today + 1.month
      end
    end

    end_date { inspection_start_date + 6.months }
  end
end
