module Availability

  class Changes < Array # TODO sorted by date ?? linked list ??

    def between(start_date, end_date)
      # start from most recent entry we have, which is the last before start_date
      start_date = most_recent_before_or_equal(start_date).try(:date) || start_date
      r = select do |change|
        (start_date..end_date).include?(change.date)
      end
      self.class.new(r)
    end

    # returns a change, the first after the date argument
    def first_after(date)
      #sort.detect {|c| c.date > date }
      select {|c| c.date > date}.sort.first
    end
    
    def end_date_of(change)
      first_after(change.date).try(:date).try(:yesterday) || Availability::Change::ETERNITY
    end
    
    # returns a change, the last before the date argument
    def most_recent_before_or_equal(date) # rename to last_before_or_equal(date) 
      select {|c| c.date <= date}.sort.last
    end

    # returns a Hash {group_id => sum_quantity}
    def available_quantities_for_groups(groups)
      group_ids = [Group::GENERAL_GROUP_ID] + groups.collect(&:id)
      map do |change|
        #selected_quantities = change.quantities.select {|q| group_ids.include?(q.group_id) }
        #[change, selected_quantities.collect(&:in_quantity).sum]
        total = change.quantities.inject(0) do |sum,q|
          group_ids.include?(q.group_id) ? sum + q.in_quantity : sum
        end      
        [change.date, total]
      end
    end

    # Ensure that a change with the given "new_change_date" exists.
    #
    # If there isn't a change on "new_change_date" then a new change
    #   will be added with the given "new_change_date".
    #
    #   The newly created change will have the same quantities
    #   associated as the change preceding it.
    #
    #   The newly created change will be returned.
    #
    # If a change with a "new_change_date" however allready exists,
    #   then that change will be returned.
    #
    def insert_or_fetch_change(new_change_date)
      change = most_recent_before_or_equal(new_change_date)
      if change.date < new_change_date
        new_change = Change.new(:date => new_change_date)
        change.quantities.each do |quantity|
          new_change.quantities << quantity.deep_clone
        end
        self << new_change
        return new_change
      else #, when change.date == new_change_date
        return change
      end
    end
  end

#########################################################

  # TODO change name ??
  class Main
    attr_reader :model_id
    attr_reader :inventory_pool_id
    attr_reader :changes # changes are allways sorted by date
    
    def initialize(attr)
      @model_id          = attr[:model_id]
      @inventory_pool_id = attr[:inventory_pool_id]
      compute
    end

    def model
      ::Model.find @model_id
    end

    def inventory_pool
      ::InventoryPool.find @inventory_pool_id
    end
        
    def compute
      initial_change = Change.new(:date => Date.today)
      current_partition = model.partitions.in(inventory_pool).current_partition
      #1402 TODO write big model_ids partition hash ?? or keep it as instance variable ??
      current_partition.each_pair do |group_id, quantity|
        initial_change.quantities << Quantity.new(:group_id => group_id, :in_quantity => quantity)
      end

      @changes = Changes.new
      @changes << initial_change

      reservations = model.running_reservations(inventory_pool)
      reservations.each do |document_line|
        start_change = @changes.insert_or_fetch_change(document_line.unavailable_from) # we don't recalculate the past
        end_change   = @changes.insert_or_fetch_change(document_line.available_again_after_today)
   
        # groups that this particular reservation can be possibly assigned to
        groups = document_line.document.user.groups.scoped_by_inventory_pool_id(inventory_pool) # optimize!
        # groups doesn't contain the general group!
        maximum = scoped_maximum_available_in_period_for_groups(groups, document_line.start_date, document_line.unavailable_until)
  
        # TODO sort groups by quantity desc
        group = groups.detect(Group::GENERAL_GROUP_ID) {|group| maximum[group] >= document_line.quantity }
  
        inner_changes = @changes.between(start_change.date, end_change.date.yesterday)
        inner_changes.each do |ic|
          qty = ic.quantities.detect {|q| q.group == group}
          qty.in_quantity  -= document_line.quantity
          qty.out_quantity += document_line.quantity
          qty.append_to_out_document_lines(document_line.class.to_s, document_line.id)
        end
      end
      # ensure changes are sorted
      @changes = Changes.new(@changes.sort_by(&:date)) # cast Array into Changes
    end

    def maximum_available_in_period_for_user(user, start_date, end_date)
      groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)
      h = @changes.between(start_date, end_date).available_quantities_for_groups(groups)
      h.sort {|a,b| a[1]<=>b[1]}.first.try(:last).to_i
    end

###########################################################
    private

    def scoped_maximum_available_in_period_for_groups(group_or_groups, start_date = Date.today, end_date = Availability::Change::ETERNITY)
      max_per_group = Hash.new
      Array(group_or_groups).each do |group|
        max_per_group[group] = minimum_in_group_between(start_date, end_date, group)
      end   
      max_per_group
    end

    def minimum_in_group_between(start_date, end_date, group)
      minimum = nil
      @changes.between(start_date, end_date).each do |change|
        quantity = change.quantities.detect { |qty| qty.group_id == group.id }
        unless quantity.nil?
          minimum = (minimum.nil? ? quantity.in_quantity : [quantity.in_quantity, minimum].min)
        end
      end
      minimum.to_i
    end

  end
end
