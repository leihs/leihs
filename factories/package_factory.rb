FactoryGirl.define do

  factory :package, parent: :model do
    is_package true
    
    factory :package_with_items do
      ignore do
        inventory_pool { FactoryGirl.create :inventory_pool }
      end
      after(:create) do |package, evaluator|
        3.times do
          package.items << FactoryGirl.create(:package_item_with_parts, :owner => evaluator.inventory_pool)
        end
      end
    end
  end
end
