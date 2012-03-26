FactoryGirl.define do

  factory :order_line do
    inventory_pool { FactoryGirl.create(:inventory_pool) }
    model { FactoryGirl.create(:model) }
    order { FactoryGirl.create(:order, :inventory_pool => inventory_pool) }
    quantity 1
    start_date { Date.today }
    end_date { Date.tomorrow }
  end
end