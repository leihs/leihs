module Availability

  ETERNITY = Date.parse("3000-01-01")
  REPLACEMENT_INTERVAL = 1.year
  
  class Change < ActiveRecord::Base
    set_table_name "availability_changes"

    belongs_to :inventory_pool, :class_name => "::InventoryPool"
    belongs_to :model, :class_name => "::Model"
    has_many :quantities, :dependent => :destroy do
                                         def general
                                           scoped_by_group_id(Group::GENERAL_GROUP_ID).first
                                         end
                                       end
  
    validates_presence_of :inventory_pool_id
    validates_presence_of :model_id
    validates_presence_of :date
  
    validates_uniqueness_of :date, :scope => [:inventory_pool_id, :model_id]
  
  #############################################
  
    default_scope :order => "date ASC, created_at ASC"
  
    named_scope :between,
                lambda { |start_date, end_date|
                         # start from most recent entry we have, which is the last before start_date
                         start_date = maximum(:date, :conditions => [ "date <= ?", start_date ]) || start_date.to_date
  
                         end_date = end_date.to_date
                         tmp_end_date = minimum(:date, :conditions => [ "date >= ?", start_date ])
                         end_date = [tmp_end_date, end_date].max if tmp_end_date
  
                         { :conditions => ["availability_changes.date BETWEEN ? AND ?", start_date, end_date] }
                }

    named_scope :overbooking,
                lambda { |inventory_pool, model|
                  conditions = ["availability_quantities.group_id IS NULL AND availability_quantities.in_quantity < 0"]
                  if inventory_pool
                    conditions[0] += " AND inventory_pool_id = ?"
                    conditions << inventory_pool
                  end
                  if model
                    conditions[0] += " AND model_id = ?"
                    conditions << model
                  end
                  { :select => "*, in_quantity",
                    :joins => :quantities,
                    :conditions => conditions
                  }
                }
                             
  #############################################
  
    # TODO refactor completely to model.availability_change with_recompute argument ??
    def self.new_partition(model, inventory_pool, group_partitioning)
      model.availability_changes.init(inventory_pool, group_partitioning)
      recompute(model, inventory_pool, false)
    end
  
    def self.recompute_all
      transaction do
        InventoryPool.all.each do |inventory_pool|
          inventory_pool.models.each do |model|
            recompute(model, inventory_pool)
          end
        end
      end
    end
  
    def self.recompute(model, inventory_pool, with_reset = true)
      reservations = model.running_reservations(inventory_pool)

      #tmp#3 bulk recompute if many lines are updated together
# OPTIMIZE
#      max_reservation = reservations.max {|a,b| a.updated_at <=> b.updated_at }.try(:updated_at)
#      if max_reservation and model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).count > 1
#        max_change = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).maximum(:updated_at)
#        return if max_reservation.to_i <= max_change.to_i
#      end

      model.availability_changes.init(inventory_pool) if with_reset
     
      reservations.each do |document_line|
        recompute_reservation(document_line)
      end
    end
  
    def self.recompute_reservation(document_line)
      # OPTIMIZE
      model = document_line.model
      inventory_pool = document_line.inventory_pool
  
      start_change = clone_change(model, inventory_pool, document_line.start_date)
      end_change = clone_change(model, inventory_pool, document_line.available_again_date)
  
      # TODO user maximum_available_in_period_for_user instead ??
      groups = document_line.document.user.groups.scoped_by_inventory_pool_id(inventory_pool) #tmp#
      maximum = maximum_available_in_period_for_groups(model, inventory_pool, groups, document_line.start_date, document_line.availability_end_date)

      # TODO sort groups by quantity desc
      group = groups.detect(Group::GENERAL_GROUP_ID) {|group| maximum[group.name] >= document_line.quantity }
      lend_out_changes(model, inventory_pool, group, document_line, start_change, end_change)
    end

    # take a model and mark one of it as lent out, thus decrementing 'in' and incerementing 'out' 
    def self.lend_out_changes(model, inventory_pool, group, document_line, start_change, end_change)
      inner_changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).all(:conditions => {:date => (start_change.date..end_change.date)}) # TODO yesterday
      inner_changes.each do |ic|
        ic.quantities.scoped_by_group_id(group).first.to_out(document_line).save
      end
      
      #tmp#6 TODO really needed ??
      end_change.quantities.scoped_by_group_id(group).first.to_in(document_line).save
    end
    
    # generate or fetch
    def self.clone_change(model, inventory_pool, date)
      # OPTIMIZE
      c = model.availability_changes.current_for_inventory_pool(inventory_pool, date)
      if c.date != date
        g = c.clone
        g.date = date
        g.save
        c.quantities.each {|q| g.quantities << q.clone }
        c = g
      end
      c
    end
  
  #############################################
  
    def next_change
      model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).first(:conditions => ["date > ?", date])
    end
  
    def start_date
      date
    end
  
    def end_date
      next_change.try(:date).try(:yesterday) || Availability::ETERNITY
    end
  
  #############################################
  
    def in_quantity_in_group(group)
      q = quantities.scoped_by_group_id(group).first
      q.try(:in_quantity).to_i
    end

    def out_quantity_in_group(group)
      q = quantities.scoped_by_group_id(group).first
      q.try(:out_quantity).to_i
    end
    
    def total_in_group(group)
      in_quantity_in_group(group) + out_quantity_in_group(group)
    end
  
  #############################################
  
    def self.maximum_available_in_period_for_user(model, inventory_pool, user, start_date, end_date)
      groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)
      maximum = maximum_available_in_period_for_groups(model, inventory_pool, groups, start_date, end_date)
      
      changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).between(start_date, end_date)
      changes << model.availability_changes.init(inventory_pool) if changes.blank?
      maximum_general = changes.collect do |c|
        c.in_quantity_in_group(Group::GENERAL_GROUP_ID)
      end
      (maximum.values << maximum_general.min.to_i).max
    end

    # how many items of #Model in a 'state' are there at most over the given period?
    #
    # returns a hash Ã  la: { 'CAST' => 2, 'Video' => 1, ... }
    #
    def self.maximum_available_in_period_for_groups(model, inventory_pool, group_or_groups, start_date = Date.today, end_date = Availability::ETERNITY)
      max_per_group = Hash.new
      Array(group_or_groups).each do |group|
        # we don't save AvailableQuantities for Groups that have zero vailable Models for space efficiency
        # reasons thus when there's an AvailabilityChange and there's no associates AvailabilityQuantity
        # then we know it's zero. So if there are more AvailabilityChanges than associated
        # AvailableQuantities then we know there are some that are null
        # TODO: move join up into has_many association
        r = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).between(start_date, end_date).minimum("ifnull(in_quantity,0)",
                    :joins => "LEFT JOIN availability_quantities " \
                              "ON availability_changes.id = availability_quantities.change_id " \
                              "AND availability_quantities.group_id = #{group.id}")
  
        max_per_group[group.name] = r.to_i
      end
  
      return max_per_group
    end

  end

end
