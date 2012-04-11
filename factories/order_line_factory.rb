FactoryGirl.define do

  factory :order_line do
    inventory_pool { FactoryGirl.create(:inventory_pool) }
    model {
      m = FactoryGirl.create(:model)
      m.items << FactoryGirl.create(:item, :model => m, :inventory_pool => inventory_pool)
      m
    }
    order { FactoryGirl.create(:order, :inventory_pool => inventory_pool) }
    quantity 1
    start_date { Date.today }
    end_date { Date.tomorrow }
  end
end