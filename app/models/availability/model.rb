module Availability
  module Model

    def self.included(base)

      base.has_many :availability_changes, :class_name => "Availability::Change" do
        def current_for_inventory_pool(inventory_pool, date = Date.today)
          scoped_by_inventory_pool_id(inventory_pool).last(:conditions => ["date <= ?", date])
        end
        
        def init(inventory_pool, new_partition = nil, date = Date.today, with_destroy = true)
          new_partition ||= current_partition(inventory_pool)

          if with_destroy and (existing_change = scoped_by_inventory_pool_id(inventory_pool).first)
            # this is much faster than destroy_all or delete_all with associations
            #tmp#6 scoped_by_inventory_pool_id(inventory_pool).destroy_all
            connection.execute("DELETE c, q, o FROM `availability_changes` AS c " \
                               " LEFT JOIN `availability_quantities` AS q ON q.`change_id` = c.`id` " \
                               " LEFT JOIN `availability_out_document_lines` AS o ON o.`quantity_id` = q.`id` " \
                               " WHERE c.`inventory_pool_id` = '#{inventory_pool.id}' " \
                               " AND c.`model_id` = '#{existing_change.model_id}'" )
          end

          initial_change = scoped_by_inventory_pool_id(inventory_pool).find_or_create_by_date(date)
          total_borrowable_items = inventory_pool.items.borrowable.scoped_by_model_id(initial_change.model).count
          general_quantity = initial_change.quantities.build(:group_id => Group::GENERAL_GROUP_ID, :in_quantity => total_borrowable_items)
    
          new_partition.delete(Group::GENERAL_GROUP_ID) # the general group is computed on the fly, then we ignore it
          
          new_partition.each_pair do |group_id, quantity|
            quantity = quantity.to_i
            next if quantity == 0 or !inventory_pool.groups.exists?(group_id)
            initial_change.quantities.create(:group_id => group_id, :in_quantity => quantity)
            general_quantity.in_quantity -= quantity
          end
          general_quantity.save

          initial_change
        end

        # how is a model distributed in the various groups?
        # returns a hash: { nil => 4, cast_group_id => 2, video_group_id => 1, ... }
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

        # generate or fetch
        def clone_change(inventory_pool, to_date)
          change = current_for_inventory_pool(inventory_pool, to_date)
          if change.nil?
            change = init(inventory_pool, nil, to_date, false)
          elsif change.date < to_date
            cloned = change.clone
            cloned.date = to_date
            cloned.save
            change.quantities.each do |quantity|
              cloned_quantity = quantity.clone
              cloned.quantities << cloned_quantity
              quantity.out_document_lines.each do |odl|
                cloned_quantity.out_document_lines << odl.clone
              end
            end
            change = cloned
          end
          change
        end
        
        def between_for_inventory_pool(inventory_pool, start_date, end_date)
          # start from most recent entry we have, which is the last before start_date
          start_date = scoped_by_inventory_pool_id(inventory_pool).maximum(:date, :conditions => [ "date <= ?", start_date ]) || start_date

          scoped_by_inventory_pool_id(inventory_pool).between(start_date, end_date)
        end

      end
      
    end

#############################################  

    # TODO remove this method, we have now the named_scope :available_quantities_for_groups
#    def available_periods_for_inventory_pool(inventory_pool, user, current_time = Date.today)
#      # TODO include additional groups where the user belongs to
#      # groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)
#
#      availability_changes.scoped_by_inventory_pool_id(inventory_pool).collect do |c|
#        q = c.in_quantity_in_group(Group::GENERAL_GROUP_ID)
#        OpenStruct.new(:start_date => c.start_date, :end_date => c.end_date, :quantity => q)
#      end
#
#    end
  
    # TODO this method is only used for test ??
    #tmp#1 test fails because uses current_time argument set in the future
    def maximum_available_for_inventory_pool(date, inventory_pool, user, current_time = Date.today)
      Availability::Change.maximum_available_in_period_for_user(self, inventory_pool, user, date, date)
    end
  
    def maximum_available_in_period_for_inventory_pool(start_date, end_date, inventory_pool, user, current_time = Date.today)
      Availability::Change.maximum_available_in_period_for_user(self, inventory_pool, user, start_date, end_date)
    end  

  end
end