FactoryGirl.define do

  factory :item_line, :aliases => [:contract_line] do
    contract
    model { FactoryGirl.create :model_with_items, :inventory_pool => contract.inventory_pool }
    purpose
    quantity 1
    start_date { contract.inventory_pool.next_open_date(Date.today) }
    end_date { contract.inventory_pool.next_open_date(start_date) }
  end
end
