FactoryGirl.define do

  trait :shared_contract_lines_attributes do
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
    purpose { FactoryGirl.create(:purpose) if status != :unsubmitted }
    start_date { inventory_pool.next_open_date(Date.today) }
    end_date { inventory_pool.next_open_date(start_date) }

    # TODO ?? contract
  end

  factory :item_line, :aliases => [:contract_line] do
    shared_contract_lines_attributes

    quantity 1
    model {
      inventory_pool.models.shuffle.detect { |model| av = model.availability_in(inventory_pool); av.partitions[nil] > 0 and av.document_lines.empty? } ||
          FactoryGirl.create(:model_with_items, :inventory_pool => inventory_pool)
    }
  end

  factory :option_line do
    shared_contract_lines_attributes

    quantity { 1 }
    option {
      inventory_pool.options.sample ||
          FactoryGirl.create(:option, :inventory_pool => inventory_pool)
    }
  end

end
