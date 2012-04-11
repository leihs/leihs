FactoryGirl.define do

  factory :contract_line do
    contract { FactoryGirl.create :contract }
    model_id { (FactoryGirl.create :model).id }
    quantity 1
    start_date { Date.today }
    end_date { Date.tomorrow }
    type { "ItemLine" }
  end
end