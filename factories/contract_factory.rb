FactoryGirl.define do

  factory :contract do
    inventory_pool
    user {
      u = FactoryGirl.create :user
      u.access_rights.create(:inventory_pool => inventory_pool, :role => Role.find_by_name("customer"))
      u
    }
    status_const 1
    
    factory :contract_with_lines do
      after_create do |contract|
        3.times do
          contract.contract_lines << FactoryGirl.create(:contract_line, :contract => contract)
        end
      end
    end
  end

end