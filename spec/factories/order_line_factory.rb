FactoryGirl.define do

  factory :order_line do
    inventory_pool { Factory :inventory_pool }
    model { Factory :model }
    order { Factory :order }
    quantity 1
  end
end