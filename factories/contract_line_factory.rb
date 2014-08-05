FactoryGirl.define do

  trait :shared_contract_lines_attributes do
    contract
    purpose
    start_date { contract.inventory_pool.next_open_date(Date.today) }
    end_date { contract.inventory_pool.next_open_date(start_date) }
  end

  factory :item_line, :aliases => [:contract_line] do
    shared_contract_lines_attributes

    quantity 1
    model { FactoryGirl.create :model_with_items, :inventory_pool => contract.inventory_pool }
  end

  factory :option_line do
    shared_contract_lines_attributes

    quantity { 1 }
    option { FactoryGirl.create :option, :inventory_pool => contract.inventory_pool }
  end

end
