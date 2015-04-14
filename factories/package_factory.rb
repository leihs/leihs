FactoryGirl.define do

  factory :package_model, parent: :model do
    is_package true
    
    factory :package_model_with_items do
      transient do
        inventory_pool { FactoryGirl.create :inventory_pool }
      end
      after(:create) do |package, evaluator|
        3.times do
          package.items << FactoryGirl.create(:package_item_with_parts, :owner => evaluator.inventory_pool)
        end
      end
    end
  end

  factory :package_item, parent: :item do
    factory :package_item_with_parts do
      after(:create) do |item, evaluator|
        3.times do
          item.children << FactoryGirl.create(:item, owner: evaluator.owner, parent: item)
        end
      end
    end
  end

end
