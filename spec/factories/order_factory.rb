FactoryGirl.define do

  factory :order do
    inventory_pool { FactoryGirl.create :inventory_pool }
    user {
      u = FactoryGirl.create :user
      u.access_rights.create(:inventory_pool => inventory_pool, :role => Role.find_by_name("customer"))
      u
    }
    status_const 1
    purpose { Faker::Lorem.sentence }
    
    factory :order_with_lines do
      after_create do |order, evaluator|
        3.times do
          order.order_lines << FactoryGirl.create(:order_line, :order => order, :inventory_pool => evaluator.inventory_pool)
        end
      end
    end
    
  end
end