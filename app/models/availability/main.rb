module Availability

  class Changes < Hash

    def between(start_date, end_date)
      # start from most recent entry we have, which is the last before start_date
      start_date = most_recent_before_or_equal(start_date).try(:date) || start_date

      keys_between = keys & (start_date..end_date).to_a
      #tmp# select {|k,v| keys_between.include?(k) }
      Hash[keys_between.map{|x| [x, self[x]]}]
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
      #tmp# k = keys.sort.reverse.detect {|x| x <= date}
      k = keys.select {|x| x <= date}.max
      self[k]
    end

    # returns a change, the first after the date argument
    def first_after(date)
      #tmp# k = keys.sort.detect {|x| x > date}
      k = keys.select {|x| x > date}.min
      self[k]
    end

  end

#########################################################

  class Main
    attr_reader :model, :inventory_pool, :document_lines, :partition, :changes
    
    def initialize(attr)
      @model          = attr[:model]
      @inventory_pool = attr[:inventory_pool]
      @inventory_pool.running_lines ||= begin
        @inventory_pool.contract_lines.handed_over_or_assigned_but_not_returned.includes(:groups) +
        @inventory_pool.order_lines.submitted.running(Date.today).includes(:groups)
      end
      # we use array select instead of sql where condition to fetch once all document_lines during the same request, instead of hit the db multiple times
      @document_lines = @inventory_pool.running_lines.select {|line| line.model_id == @model.id}
      @partition      = @inventory_pool.partitions_with_generals.hash_for_model(@model)
      compute
    end

    def compute
      initial_change = Change.new(:date => Date.today)
      @partition.each_pair do |group_id, quantity|
        initial_change.quantities[group_id] = Quantity.new(:group_id => group_id, :in_quantity => quantity)
      end
      @changes = Changes[initial_change.date => initial_change]
      inventory_pool_groups = @inventory_pool.groups

      @document_lines.each do |document_line|
        # this is the order on the groups we check on:   
        # 1. groups that this particular document_line can be possibly assigned to, TODO sort groups by quantity desc ??
        # 2. general group
        # 3. groups which the user is not even member
        groups_to_check = (document_line.groups & inventory_pool_groups) + [Group::GENERAL_GROUP_ID] + (inventory_pool_groups - document_line.groups)
        maximum = available_quantities_for_groups(groups_to_check, @changes.between(document_line.start_date, document_line.unavailable_until(@model)))
        # if still no group has enough available quantity, we allocate to general as fallback
        group = groups_to_check.detect(proc {Group::GENERAL_GROUP_ID}) {|group| maximum[group.try(:id)] >= document_line.quantity }
        document_line.allocated_group = group
  
        start_change = @changes.insert_or_fetch_change(document_line.unavailable_from) # we don't recalculate the past
        end_change   = @changes.insert_or_fetch_change(document_line.available_again_after_today(@model))
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
      available_quantities_for_groups([Group::GENERAL_GROUP_ID] + groups, @changes.between(start_date, end_date)).values.max
    end

    def available_total_quantities
      @changes.map do |date, change|
        total = change.quantities.values.sum(&:in_quantity)
        groups = change.quantities.map do |g, q|
          { :group_id => g,
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
      group_ids = groups.map{|g| g.try(:id)}
      group_ids.each do |group_id|
        h[group_id] = c.values.map{|c| c.quantities[group_id].try(:in_quantity).to_i }.min.to_i
      end
      h
    end

  end
end
