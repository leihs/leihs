FactoryGirl.define do

  factory :package_item, parent: :item do
    
    factory :package_item_with_parts do
      after(:create) do |item, evaluator|
        3.times do
          item.children << FactoryGirl.create(:item, :owner => evaluator.owner)
        end
      end
    end
  end
end