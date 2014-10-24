FactoryGirl.define do

  factory :contract do
    inventory_pool
    user {
      u1 = inventory_pool.users.customers.sample
      u1 ||= begin
        u2 = FactoryGirl.create :user
        u2.access_rights.create(:inventory_pool => inventory_pool, :role => :customer)
        u2
      end
      u1
    }
    status { :unsubmitted }
    delegated_user { user.delegated_users.sample if user.is_delegation }

    factory :contract_with_lines do
      ignore do
        lines_count { rand(3..6) }
      end
      after(:create) do |contract, evaluator|
        purpose = FactoryGirl.create(:purpose) unless contract.status == :unsubmitted
        evaluator.lines_count.times do
          contract.contract_lines << FactoryGirl.create(:contract_line, :contract => contract, purpose: purpose)
        end
      end
    end
  end
end
