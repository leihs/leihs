module Availability2
  module Model

    def self.included(base)

      base.has_many :availability_changes, :class_name => "Availability2::Change" do
        def current_for_inventory_pool(inventory_pool)
          r = scoped_by_inventory_pool_id(inventory_pool).last(:conditions => ["date <= ?", Date.today])
          r ||= reset_for_inventory_pool(inventory_pool)
        end
        
        def reset_for_inventory_pool(inventory_pool)
          scoped_by_inventory_pool_id(inventory_pool).destroy_all
          initial_change = scoped_by_inventory_pool_id(inventory_pool).create(:date => Date.today)
          #tmp#1
          total_borrowable_items = inventory_pool.items.borrowable.scoped_by_model_id(initial_change.model).count
          initial_change.quantities.create(:group_id => Group::GENERAL_GROUP_ID, :in_quantity => total_borrowable_items)
          initial_change
        end
      end
      
    end

#############################################  

    def available_periods_for_inventory_pool(inventory_pool, user, current_time = Date.today)
      # TODO include additional groups where the user belongs to
      # groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)

      availability_changes.scoped_by_inventory_pool_id(inventory_pool).collect do |c|
        q = c.in_quantity_in_group(Group::GENERAL_GROUP_ID)
        { :start_date => c.start_date,
          :end_date => c.end_date,
          :quantity => q }        
      end

    end
  
    # OPTIMIZE this method is only used for test ??  
    def maximum_available_for_inventory_pool(date, inventory_pool, user, current_time = Date.today)
      Availability2::Change.maximum_available_in_period_for_user(self, inventory_pool, user, date, date)
    end
    
    def maximum_available_in_period_for_document_line(start_date, end_date, document_line, current_time = Date.today)
      # TODO
      r = Availability2::Change.maximum_available_in_period_for_user(self, document_line.inventory_pool, document_line.document.user, start_date, end_date)
      r + document_line.quantity
    end  
  
    def maximum_available_in_period_for_inventory_pool(start_date, end_date, inventory_pool, user, current_time = Date.today)
      Availability2::Change.maximum_available_in_period_for_user(self, inventory_pool, user, start_date, end_date)
    end  

  end
end