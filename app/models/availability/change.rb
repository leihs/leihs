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
  
#tmp#10    validates_uniqueness_of :date, :scope => [:inventory_pool_id, :model_id]
  
  #############################################
  
    default_scope :order => "date ASC, created_at ASC"
  
    named_scope :between,
                lambda { |start_date, end_date|
                         { :conditions => ["availability_changes.date BETWEEN ? AND ?", start_date, end_date] }
                }

    named_scope :overbooking, :select => "*, SUM(in_quantity) AS available_quantity",
                              :joins => :quantities,
                              :conditions => ["availability_quantities.in_quantity < 0"],
                              :group => "availability_changes.id"

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
          model.availability_changes.in(inventory_pool).recompute
        end
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

    # TODO refactor as nested method "model...in(inventory_pool)..."
    def self.maximum_available_in_period_for_user(model, inventory_pool, user, start_date, end_date)
#old#      
#      groups = [Group::GENERAL_GROUP_ID]
#      groups += user.groups.scoped_by_inventory_pool_id(inventory_pool) if user
#      maximum_for_groups = maximum_available_in_period_for_groups(model, inventory_pool, groups, start_date, end_date)
#      maximum_for_groups.values.sum

      groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)
      # OPTIMIZE use MIN() instead of ORDER BY ??
      change = model.availability_changes.in(inventory_pool).between_from_most_recent_start_date(start_date, end_date).available_quantities_for_groups(groups).first(:order => "available_quantity ASC")
      change.try(:available_quantity).to_i
    end

    # TODO this is only used in tests, remove and use nested method scoped_maximum_available_in_period_for_groups instead
    # how many items of #Model in a 'state' are there at most over the given period?
    # returns a hash: { 'CAST' => 2, 'Video' => 1, ... }
#    def self.maximum_available_in_period_for_groups(model, inventory_pool, group_or_groups, start_date = Date.today, end_date = Availability::ETERNITY)
#      max_per_group = Hash.new
#      Array(group_or_groups).each do |group|
#        # we don't save AvailableQuantities for Groups that have zero vailable Models for space efficiency
#        # reasons thus when there's an AvailabilityChange and there's no associates AvailabilityQuantity
#        # then we know it's zero. So if there are more AvailabilityChanges than associated
#        # AvailableQuantities then we know there are some that are null
#        # TODO: move join up into has_many association
#        
#        joins = "LEFT JOIN availability_quantities ON availability_changes.id = availability_quantities.change_id AND availability_quantities.group_id "
#        joins += (group.nil? ? "IS NULL" : "= #{group.id}" )
#        
#        r = model.availability_changes.in(inventory_pool).between_from_most_recent_start_date(start_date, end_date).minimum("ifnull(in_quantity,0)", :joins => joins)
#  
#        max_per_group[group] = r.to_i
#      end
#  
#      return max_per_group
#    end

  end

end
