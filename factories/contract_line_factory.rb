FactoryGirl.define do

  factory :item_line, :aliases => [:contract_line] do
    contract
    model { FactoryGirl.create :model_with_items, :inventory_pool => contract.inventory_pool }
    purpose
    quantity 1
    start_date { contract.inventory_pool.next_open_date(Date.today) }
    end_date { contract.inventory_pool.next_open_date(start_date) }
  end

  factory :option_line do
    contract
    option { FactoryGirl.create :option, :inventory_pool => contract.inventory_pool }
    purpose
    quantity 1
    start_date { Date.today }
    end_date { Date.today + 1.day } # NOTE do not use Date.tomorrow because we are overriding Date.today in features/support/helper.rb
  end

end
