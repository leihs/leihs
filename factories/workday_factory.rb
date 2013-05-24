FactoryGirl.define do

  factory :workday do
    inventory_pool
    monday {random > 0.5}
    tuesday {random > 0.5}
    wednesday {random > 0.5}
    thursday {random > 0.5}
    friday {random > 0.5}
    saturday {random > 0.5}
    sunday {random > 0.5}
  end

end