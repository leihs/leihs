module Availability

  ETERNITY = Date.parse("3000-01-01")
  REPLACEMENT_INTERVAL = 1.month #1.year
  
  class Change < ActiveRecord::Base
    set_table_name "availability_changes"


    belongs_to :inventory_pool, :class_name => "::InventoryPool"
    belongs_to :model, :class_name => "::Model"
    has_many :quantities, :class_name => "Availability::Quantity",
                          :dependent => :destroy do
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
                         { :conditions => ["availability_changes.date BETWEEN ? AND ?", start_date, end_date] }
                }

    named_scope :overbooking,
                lambda { |inventory_pool, model|
                  conditions = ["availability_quantities.group_id IS NULL AND availability_quantities.in_quantity < 0"] # NULL is Group::GENERAL_GROUP_ID
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

    named_scope :available_quantities_for_groups,
                lambda { |groups|
                  { :select => "*, SUM(in_quantity) AS available_quantity",
                    :joins => :quantities,
                    :conditions => ["availability_quantities.group_id IS NULL OR availability_quantities.group_id IN (?)", groups], # NULL is Group::GENERAL_GROUP_ID
                    :group => "availability_changes.id" }
                }
                             
  #############################################
  
    def self.recompute_all
      ::InventoryPool.all.each do |inventory_pool|
        inventory_pool.models.each do |model|
          recompute(model, inventory_pool)
        end
      end
    end
  
    def self.recompute(model, inventory_pool, new_partition = nil)
      reservations = model.running_reservations(inventory_pool)

      #tmp#6 OPTIMIZE bulk recompute if many lines are updated together
      if new_partition.nil?
        max_reservation = reservations.max {|a,b| a.updated_at <=> b.updated_at }.try(:updated_at)
        if max_reservation and model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).count > 1
          max_change = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).maximum(:updated_at)
          return if max_reservation.to_i <= max_change.to_i
        end
      end

      transaction do
        model.availability_changes.init(inventory_pool, new_partition)
     
        reservations.each do |document_line|
          recompute_reservation(document_line)
        end
      end
    end
  
    def self.recompute_reservation(document_line)
      # OPTIMIZE
      model = document_line.model
      inventory_pool = document_line.inventory_pool
  
      start_change = model.availability_changes.clone_change(inventory_pool, [document_line.start_date, Date.today].max) # we don't recalculate the past
      end_change = model.availability_changes.clone_change(inventory_pool, document_line.available_again_date)
  
      groups = document_line.document.user.groups.scoped_by_inventory_pool_id(inventory_pool)
      maximum = maximum_available_in_period_for_groups(model, inventory_pool, groups, document_line.start_date, document_line.availability_end_date)

      # TODO sort groups by quantity desc
      group = groups.detect(Group::GENERAL_GROUP_ID) {|group| maximum[group] >= document_line.quantity }

      inner_changes = model.availability_changes.between_for_inventory_pool(inventory_pool, start_change.date, end_change.date.yesterday)
      inner_changes.each do |ic|
        ic.quantities.scoped_by_group_id(group).first.to_out(document_line).save
      end
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
      groups = [Group::GENERAL_GROUP_ID]
      groups += user.groups.scoped_by_inventory_pool_id(inventory_pool) if user
      maximum_for_groups = maximum_available_in_period_for_groups(model, inventory_pool, groups, start_date, end_date)
      maximum_for_groups.values.sum
    end

    # how many items of #Model in a 'state' are there at most over the given period?
    # returns a hash: { 'CAST' => 2, 'Video' => 1, ... }
    def self.maximum_available_in_period_for_groups(model, inventory_pool, group_or_groups, start_date = Date.today, end_date = Availability::ETERNITY)
      max_per_group = Hash.new
      Array(group_or_groups).each do |group|
        # we don't save AvailableQuantities for Groups that have zero vailable Models for space efficiency
        # reasons thus when there's an AvailabilityChange and there's no associates AvailabilityQuantity
        # then we know it's zero. So if there are more AvailabilityChanges than associated
        # AvailableQuantities then we know there are some that are null
        # TODO: move join up into has_many association
        
        joins = "LEFT JOIN availability_quantities ON availability_changes.id = availability_quantities.change_id AND availability_quantities.group_id "
        joins += (group.nil? ? "IS NULL" : "= #{group.id}" )
        
        r = model.availability_changes.between_for_inventory_pool(inventory_pool, start_date, end_date).minimum("ifnull(in_quantity,0)", :joins => joins)
  
        max_per_group[group] = r.to_i
      end
  
      return max_per_group
    end

  end

end
