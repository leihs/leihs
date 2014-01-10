FactoryGirl.define do

  factory :option_line do
    contract
    option { FactoryGirl.create :option, :inventory_pool => contract.inventory_pool }
    purpose
    quantity 1
    start_date { Date.today }
    end_date { Date.today + 1.day } # NOTE do not use Date.tomorrow because we are overriding Date.today in features/support/helper.rb 
  end
end
