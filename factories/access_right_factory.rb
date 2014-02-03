FactoryGirl.define do

  factory :access_right do
    role { :customer }
    user
    inventory_pool
  end

end
