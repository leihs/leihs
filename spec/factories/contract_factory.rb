FactoryGirl.define do

  factory :contract do
    user { FactoryGirl.create(:user) }
    inventory_pool { FactoryGirl.create :inventory_pool }
    status_const 1
    purpose { Faker::Lorem.sentence }
  end
end