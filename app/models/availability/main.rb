module Availability

  class Changes < Hash

    def between(start_date, end_date)
      # start from most recent entry we have, which is the last before start_date
      start_date = most_recent_before_or_equal(start_date).try(:date) || start_date
      select {|k,v| (start_date..end_date).include?(k) }
    end

    def end_date_of(date)
      first_after(date).try(:date).try(:yesterday) || Availability::Change::ETERNITY
    end
        
    # Ensure that a change with the given "new_change_date" exists.
    # If there isn't a change on "new_change_date" then a new change will be added with the given "new_change_date".
    #   The newly created change will have the same quantities associated as the change preceding it.
    #   The newly created change will be returned.
    # If a change with a "new_change_date" however allready exists, then that change will be returned.
    def insert_or_fetch_change(new_change_date)
      if change = self[new_change_date]
        return change
      else
        change = most_recent_before_or_equal(new_change_date)
        new_change = Change.new(:date => new_change_date)
        new_change.quantities = Marshal.load( Marshal.dump(change.quantities) ) # NOTE this keeps references: change.quantities.dup
        return self[new_change.date] = new_change
      end
    end

    private
    
    # returns a change, the last before the date argument
    def most_recent_before_or_equal(date) # TODO ?? rename to last_before_or_equal(date)
      self[keys.sort.reverse.detect {|x| x <= date}]
    end

    # returns a change, the first after the date argument
    def first_after(date)
      self[keys.sort.detect {|x| x > date}]
    end

  end

#########################################################

  class Main
    attr_reader :model, :inventory_pool, :document_lines, :partition, :changes
    
    def initialize(attr)
      @model          = attr[:model]
      @inventory_pool = attr[:inventory_pool]
      @document_lines = begin
        @model.contract_lines.by_inventory_pool(@inventory_pool).handed_over_or_assigned_but_not_returned +
        @model.order_lines.scoped_by_inventory_pool_id(@inventory_pool).submitted.running(Date.today)
      end.sort_by(&:start_date)
      @partition      = @model.partitions.in(@inventory_pool).current_partition
      compute
    end

    def compute
      initial_change = Change.new(:date => Date.today)
      @partition.each_pair do |group_id, quantity|
        initial_change.quantities[group_id] = Quantity.new(:group_id => group_id, :in_quantity => quantity)
      end

      @changes = Changes[initial_change.date => initial_change]

      @document_lines.each do |document_line|
        start_change = @changes.insert_or_fetch_change(document_line.unavailable_from) # we don't recalculate the past
        end_change   = @changes.insert_or_fetch_change(document_line.available_again_after_today(@model))
   
        # groups that this particular document_line can be possibly assigned to
        groups = document_line.groups & @inventory_pool.groups
        # groups doesn't contain the general group! then we add it manually
        groups_with_general = groups + [Group::GENERAL_GROUP_ID]
        maximum = scoped_maximum_available_in_period_for_groups(groups_with_general, document_line.start_date, document_line.unavailable_until(@model))
  
        # TODO sort groups by quantity desc
        # currently the general is the last one!
        group = groups_with_general.detect {|group| maximum[group] >= document_line.quantity }
        
        # if no user's group or general has enough available quantity,
        # we force to allocate to a group which the user is not even member
        group ||= begin
          # reset groups and maximum
          groups = @inventory_pool.groups
          maximum = scoped_maximum_available_in_period_for_groups(groups, document_line.start_date, document_line.unavailable_until(@model))
          # if still no group has enough available quantity, we allocate to general as fallback
          groups.detect(proc {Group::GENERAL_GROUP_ID}) {|group| maximum[group] >= document_line.quantity }
        end
        document_line.allocated_group = group
  
        inner_changes = @changes.between(start_change.date, end_change.date.yesterday)
        inner_changes.each_pair do |key, ic|
          qty = ic.quantities[group.try(:id)]
          qty.in_quantity  -= document_line.quantity
          qty.out_quantity += document_line.quantity
          qty.append_to_out_document_lines(document_line.class.to_s, document_line.id)
        end
      end
    end
    
    def maximum_available_in_period_for_groups(groups, start_date, end_date)
      groups &= @inventory_pool.groups
      available_quantities_for_groups(groups, @changes.between(start_date, end_date)).values.max
    end

    def available_total_quantities
      @changes.map do |date, change|
        total = change.quantities.values.sum(&:in_quantity)
        groups = change.quantities.map do |g, q|
          { :group_id => g.try(:to_i),
            :name => q.group.try(:name),
            :in_quantity => q.in_quantity,
            :out_document_lines => q.out_document_lines }
        end
        [date, total, groups]
      end
    end

    # returns a Hash {group_id => quantity}
    def available_quantities_for_groups(groups, c = nil)
      c ||= @changes
      h = {}
      group_ids = [Group::GENERAL_GROUP_ID] + groups.map(&:id)
      group_ids.each do |group_id|
        h[group_id] = c.values.map{|c| c.quantities[group_id].try(:in_quantity).to_i }.min
      end
      h
    end

###########################################################
    private

    def scoped_maximum_available_in_period_for_groups(group_or_groups, start_date = Date.today, end_date = Availability::Change::ETERNITY)
      max_per_group = Hash.new
      Array(group_or_groups).each do |group|
        max_per_group[group] = begin
          minimum = nil
          @changes.between(start_date, end_date).each_pair do |key, change|
            if quantity = change.quantities[group.try(:id)]
              minimum = (minimum.nil? ? quantity.in_quantity : [quantity.in_quantity, minimum].min)
            end
          end
          minimum.to_i
        end
      end   
      max_per_group
    end

  end
end
