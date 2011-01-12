module Availability
  module Model
  
    def self.included(base)
      base.has_many :availability_changes, :class_name => "Availability::Change", 
                                           :dependent => :destroy do
        # 'in' is our named_scope that returns an object that is extended by methods
        # allowing to work inside that named scope. I hope this gets garbage collected
        # correctly...
        def in(ip)
          @inventory_pool = ip
          @model = proxy_owner

          class << self # add methods to our scope
            include AvailabilityScopedByInventoryPool
          end

          scoped( { :conditions => {:inventory_pool_id => @inventory_pool} } )
        end
      end
      
      # NOTE thinking_sphinx ignores the nested_has_many_through plugin, thatfore we have to provide the sql explicitly
      #base.has_many :availability_quantities, :through => :availability_changes, :source => :quantities
      #base.has_many :groups, :through => :availability_quantities, :uniq => true, :conditions => "(in_quantity + out_quantity) > 0"
#tmp#2911 we provide the sql directly within the define_index
#      base.has_many :groups, :finder_sql => 'SELECT DISTINCT `groups`.* ' +
#                                            'FROM `groups` ' +
#                                            ' INNER JOIN availability_quantities ON ( groups.id = availability_quantities.group_id ) ' +
#                                            ' INNER JOIN availability_changes ON ( availability_quantities.change_id = availability_changes.id ) ' +
#                                            'WHERE (availability_changes.model_id = #{id} ' +
#                                            ' AND (in_quantity + out_quantity) > 0)'
    end
  
    # depends on @inventory_pool and @model to be set, in order to work
    module AvailabilityScopedByInventoryPool
              
      def drop_changes
        # this is much faster than destroy_all or delete_all with associations
        connection.execute("DELETE c, q FROM `availability_changes` AS c " \
                           " LEFT JOIN `availability_quantities` AS q ON q.`change_id` = c.`id` " \
                           " WHERE c.`inventory_pool_id` = '#{@inventory_pool.id}' " \
                           " AND c.`model_id` = '#{@model.id}'" )
      end
      
      def recompute(new_partition = nil)
          @new_changes = []
       
          def most_recent_change(date)
             @new_changes.select {|c| c.date <= date}.sort {|a,b| a.date <=> b.date}.last
          end
  
          def scoped_between(start_date, end_date)
            start_date = most_recent_change(start_date).try(:date) || start_date
            @new_changes.select do |change|
              change.date >= start_date && change.date <= end_date
            end
          end
  
          def minimum_in_group_between(start_date, end_date, group)
            # we don't save AvailableQuantities for Groups that have zero available Models for space efficiency
            # reasons thus when there's an AvailabilityChange and there's no associates AvailabilityQuantity
            # then we know it's zero. So if there are more AvailabilityChanges than associated
            # AvailableQuantities then we know there are some that are null
            # TODO: move join up into has_many association
            minimum = nil
            scoped_between(start_date, end_date).each do |change|
              quantity = change.quantities.detect { |qty| qty.group == group }
              unless quantity.nil?
                minimum = (minimum.nil? ? quantity.in_quantity : [quantity.in_quantity, minimum].min)
              end
            end
            minimum.to_i
          end
  
          # DUPLICATION OF CODE
          def scoped_maximum_available_in_period_for_groups(group_or_groups, start_date = Date.today, end_date = Availability::ETERNITY)
            max_per_group = Hash.new
            Array(group_or_groups).each do |group|
              max_per_group[group] = minimum_in_group_between(start_date, end_date, group)
            end   
            max_per_group
          end

          transaction do
            reservations = @model.running_reservations(@inventory_pool)

            #tmp#6 OPTIMIZE bulk recompute if many lines are updated together
            # TODO we really need a filter to prevent double/triple recomputations??
            #      if new_partition.nil?
            #        max_reservation = reservations.max {|a,b| a.updated_at <=> b.updated_at }.try(:updated_at)
            #        if max_reservation and model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).count > 1
            #          max_change = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).maximum(:updated_at)
            #          return if max_reservation.to_i <= max_change.to_i
            #        end
            #      end

            new_partition ||= current_partition     

            total_borrowable_items = @inventory_pool.items.borrowable.scoped_by_model_id(@model.id).count
            initial_change = build(:date => Date.today)
            general_quantity = initial_change.quantities.build(:group_id => Group::GENERAL_GROUP_ID, :in_quantity => total_borrowable_items, :out_quantity => 0)

            valid_group_ids = @inventory_pool.group_ids

            new_partition.delete(Group::GENERAL_GROUP_ID) # the general group is computed on the fly, then we ignore it
            new_partition.each_pair do |group_id, quantity|
              group_id = group_id.to_i
              quantity = quantity.to_i
              next if quantity == 0 or !valid_group_ids.include?(group_id)
              initial_change.quantities.build(:group_id => group_id, :in_quantity => quantity)
              general_quantity.in_quantity -= quantity
            end

            @new_changes << initial_change
          
            reservations.each do |document_line|
              start_change = clone_change(document_line.unavailable_from) # we don't recalculate the past
              end_change = clone_change(document_line.available_again_after_today)
         
              groups = document_line.document.user.groups.scoped_by_inventory_pool_id(@inventory_pool) # optimize!
              # groups doesn't contain the general group!
              maximum = scoped_maximum_available_in_period_for_groups(groups, document_line.start_date, document_line.unavailable_until)
        
              # TODO sort groups by quantity desc
              group = groups.detect(Group::GENERAL_GROUP_ID) {|group| maximum[group] >= document_line.quantity }
        
              inner_changes = scoped_between(start_change.date, end_change.date.yesterday)
              inner_changes.each do |ic|
                qty = ic.quantities.detect {|q| q.group == group}
                qty.in_quantity  -= document_line.quantity
                qty.out_quantity += document_line.quantity
                qty.append_to_out_document_lines(document_line.class.to_s, document_line.id)
              end
            end

            drop_changes
            @new_changes.each {|x| x.save }
            # if there's no more items of a model in a group accessible to the customer,
            # then he shouldn't be able to see the model in the frontend. Therefore we need to reindex
            @model.touch_for_sphinx # trigger sphinx reindex   #OPTIMIZE: only reindex frontend data
          end # transaction          
      end # recompute
      
      
      # how is a model distributed in the various groups?
      # returns a hash: { nil => 4, cast_group_id => 2, video_group_id => 1, ... }
      def current_partition
        partitioning = {}
        existing_change = first
        if existing_change
          existing_change.quantities.map do |q|
            partitioning[q.group_id] = q.in_quantity + q.out_quantity
          end
        else
          # TODO ??
          # total_borrowable_items = @inventory_pool.items.borrowable.scoped_by_model_id(@model.id).count
          # partitioning[Group::GENERAL_GROUP_ID] = total_borrowable_items
        end
        partitioning
      end
      
      # generate or fetch
      def clone_change(to_date)
        change = most_recent_change(to_date)
        if change.date < to_date
          cloned = build(:date => to_date)
          change.quantities.each do |quantity|
            cloned_quantity = cloned.quantities.build( :out_quantity => quantity.out_quantity,
                                                       :in_quantity  => quantity.in_quantity,
                                                       :group_id     => quantity.group_id,
                                                       :out_document_lines => quantity.out_document_lines)
          end
          @new_changes << cloned
          return cloned
        else
          return change
        end
      end
      
      def between_from_most_recent_start_date(start_date, end_date)
        # start from most recent entry we have, which is the last before start_date
        start_date = maximum(:date, :conditions => [ "date <= ?", start_date ]) || start_date
        between(start_date, end_date)
      end

      def recompute_if_empty
        recompute if empty?
        all
      end

      def maximum_available_in_period_for_user(user, start_date, end_date)
        groups = user.groups.scoped_by_inventory_pool_id(@inventory_pool)
        # OPTIMIZE use MIN() instead of ORDER BY ??
        change = between_from_most_recent_start_date(start_date, end_date).available_quantities_for_groups(groups).first(:order => "available_quantity ASC")
        change.try(:available_quantity).to_i
      end
    end

  end
end
