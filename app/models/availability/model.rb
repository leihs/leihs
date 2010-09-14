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
          new_partition ||= current_partition(inventory_pool)

          scoped_by_inventory_pool_id(inventory_pool).destroy_all
          initial_change = scoped_by_inventory_pool_id(inventory_pool).create(:date => Date.today)
          total_borrowable_items = inventory_pool.items.borrowable.scoped_by_model_id(initial_change.model).count
          general_quantity = initial_change.quantities.build(:group_id => Group::GENERAL_GROUP_ID, :in_quantity => total_borrowable_items)
    
          new_partition.delete(Group::GENERAL_GROUP_ID) # the general group is computed on the fly, then we ignore it
          new_partition.each_pair do |group_id, quantity|
            quantity = quantity.to_i
            initial_change.quantities.create(:group_id => group_id, :in_quantity => quantity) if quantity > 0
            general_quantity.in_quantity -= quantity
          end
          general_quantity.save

          initial_change
        end

        # how is a model distributed in the various groups?
        # returns a hash Ã  la: { nil => 4, cast_group_id => 2, video_group_id => 1, ... }
        def current_partition(inventory_pool)
          partitioning = {}
          existing_change = scoped_by_inventory_pool_id(inventory_pool).first

          if existing_change
            existing_change.quantities.map do |q|
              partitioning[q.group_id] = q.in_quantity + q.out_quantity
            end
          else
            # TODO ??
            # total_borrowable_items = inventory_pool.items.borrowable.scoped_by_model_id(initial_change.model).count
            # partitioning[Group::GENERAL_GROUP_ID] = total_borrowable_items
          end
          
          partitioning
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