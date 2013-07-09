FactoryGirl.define do

  factory :order_line do
    inventory_pool { FactoryGirl.create(:inventory_pool) }
    model {
      m = FactoryGirl.create(:model)
      rand(1..5).times do
        m.items << FactoryGirl.create(:item, :model => m, :inventory_pool => inventory_pool)
      end
      m
    }
    order { FactoryGirl.create(:order, :inventory_pool => inventory_pool) }
    quantity 1
    start_date { inventory_pool.next_open_date(rand(1..300).days.from_now.to_date) }
    end_date { inventory_pool.next_open_date(start_date + rand(1..300).days) }
  end
end