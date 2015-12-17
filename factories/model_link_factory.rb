FactoryGirl.define do

  factory :model_link do
    model_group { FactoryGirl.create :model_group }
    model { FactoryGirl.create :model }
    quantity { 1 }
  end
end
