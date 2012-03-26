FactoryGirl.define do

  factory :contract_line do
    contract { Factory :contract }
    model_id { (Factory :model).id }
    quantity 1
    start_date { Date.today }
    end_date { Date.tomorrow }
    type { "ItemLine" }
  end
end