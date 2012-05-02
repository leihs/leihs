FactoryGirl.define do

  factory :item_line, :aliases => [:contract_line] do
    contract { FactoryGirl.create :contract }
    model_id { (FactoryGirl.create :model).id }
    quantity 1
    start_date { Date.today }
    end_date { Date.tomorrow }
  end
end