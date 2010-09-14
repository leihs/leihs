module Availability
  module Model

    def self.included(base)

      base.has_many :availability_changes, :class_name => "Availability::Change" do
        def current_for_inventory_pool(inventory_pool, date = Date.today)
          r = scoped_by_inventory_pool_id(inventory_pool).last(:conditions => ["date <= ?", date])
          r ||= scoped_by_inventory_pool_id(inventory_pool).last(:conditions => ["date <= ?", Date.today]) if date != Date.today
          r ||= init(inventory_pool)
        end
        
        def init(inventory_pool, new_partition = nil)
#working here#
#          if new_partition
#            initial_change = scoped_by_inventory_pool_id(inventory_pool).first
#            general_quantity = initial_change.quantities.general
#      
#            group_partitioning.delete(Group::GENERAL_GROUP_ID) # the general group is computed on the fly, then we ignore it
#            group_partitioning.each_pair do |group_id, quantity|
#              quantity = quantity.to_i
#              initial_change.quantities.create(:group_id => group_id, :in_quantity => quantity) if quantity > 0
#              general_quantity.in_quantity -= quantity
#            end if group_partitioning
#            general_quantity.save
#          end
          
#          partitions = Availability::Change.partitions(self, inventory_pool)
#          Availability::Change.new_partition(self, inventory_pool, partitions)

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
      Availability::Change.maximum_available_in_period_for_user(self, inventory_pool, user, date, date)
    end
    
    def maximum_available_in_period_for_document_line(start_date, end_date, document_line, current_time = Date.today)
      # TODO
      r = Availability::Change.maximum_available_in_period_for_user(self, document_line.inventory_pool, document_line.document.user, start_date, end_date)
      r + document_line.quantity
    end  
  
    def maximum_available_in_period_for_inventory_pool(start_date, end_date, inventory_pool, user, current_time = Date.today)
      Availability::Change.maximum_available_in_period_for_user(self, inventory_pool, user, start_date, end_date)
    end  

  end
end