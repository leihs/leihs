class AvailabilityChange < ActiveRecord::Base
  belongs_to :inventory_pool
  belongs_to :model
  has_many :available_quantities, :dependent => :destroy

  validates_presence_of :inventory_pool_id
  validates_presence_of :model_id
  validates_presence_of :date

#############################################

  default_scope :order => "date ASC, created_at ASC"

  named_scope :between,
              lambda { |start_date, end_date|
              
                       start_date = start_date.to_date
                       end_date = end_date.to_date
                       
                       # start from most recent entry we have, which is the last before start_date.
                       # If there's no previous entry then use the date we have
                       start_date = AvailabilityChange.maximum(:date, :conditions => [ "date <= ?", start_date ]) \
                                    || start_date                
                       
                       { :conditions => ["availability_changes.date BETWEEN ? AND ?", start_date, end_date] }
              }
              
#############################################

  def self.recompute(model, inventory_pool)
    # TODO keep manager definition and delete others 
    #model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).destroy_all
    current_changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool)
    
    # TODO the last change should describe all in_stock partition
    defined_change = current_changes.last
    defined_change ||= model.availability_changes.new_current_for_inventory_pool(inventory_pool)
    
    reservations = model.running_reservations(inventory_pool)
    reservations.each do |r|
      groups = r.document.user.groups.scoped_by_inventory_pool_id(inventory_pool) & defined_change.available_quantities.collect(&:group)
      # TODO sort groups by quantity desc
      maximum = maximum_in_state_in_period(model, inventory_pool, groups, r.start_date, r.end_date, AvailableQuantity::AVAILABLE)
      groups.each do |g|
        if maximum[g.name] >= r.quantity
          model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).create(:date => r.start_date)
          # TODO quantities
          model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).create(:date => r.end_date)
          # TODO quantities
          break
        end
      end
    end
    
    # TODO compact on dates
  end

#############################################

  def borrowable_in_stock_total
    inventory_pool.items.borrowable.in_stock.scoped_by_model_id(model).count
  end

  def borrowable_not_in_stock_total
    inventory_pool.items.borrowable.not_in_stock.scoped_by_model_id(model).count
  end

  def unborrowable_in_stock_total
    inventory_pool.items.unborrowable.in_stock.scoped_by_model_id(model).count
  end

  def unborrowable_not_in_stock_total
    inventory_pool.items.unborrowable.not_in_stock.scoped_by_model_id(model).count
  end


  def general_borrowable_in_stock_size
    borrowable_in_stock_total - available_quantities.available.sum(:quantity).to_i
  end

  def general_borrowable_not_in_stock_size
    borrowable_not_in_stock_total - available_quantities.borrowed.sum(:quantity).to_i
  end
  
  def total_in_group(group)
    # TODO exclude unborrowable ??
    available_quantities.scoped_by_group_id(group).sum(:quantity).to_i
  end

#############################################

  def self.maximum_available_in_period(model, inventory_pool, group_or_groups, start_date, end_date)
    maximum_in_state_in_period(model, inventory_pool, group_or_groups, start_date, end_date, AvailableQuantity::AVAILABLE)
  end

  def self.maximum_borrowed_in_period(model, inventory_pool, group_or_groups, start_date, end_date)
    maximum_in_state_in_period(model, inventory_pool, group_or_groups, start_date, end_date, AvailableQuantity::BORROWED)
  end

  def self.maximum_borrowed_in_period(model, inventory_pool, group_or_groups, start_date, end_date)
    maximum_in_state_in_period(model, inventory_pool, group_or_groups, start_date, end_date, AvailableQuantity::UNBORROWABLE)
  end

  # how many items of #Model in a 'state' are there at most over the given period?
  #
  # returns a hash à la: { 'General' => 4, 'CAST' => 2, ... }
  #
  def self.maximum_in_state_in_period(model, inventory_pool, groups, start_date, end_date, state)
    start_date = start_date.to_date
    end_date = end_date.to_date
    # start from most recent entry we have, which is the last before start_date
    start_date = AvailabilityChange.maximum(:date, :conditions => [ "date > ?", start_date ]) \
                 || start_date

    max_per_group = Hash.new
    Array(groups).each do |group|
      # we don't save AvailableQuantities for Groups that have zero vailable Models for space efficiency
      # reasons thus when there's an AvailabilityChange and there's no associates AvailabilityQuantity
      # then we know it's zero. So if there are more AvailabilityChanges than associated
      # AvailableQuantities then we know there are some that are null
      # TODO: move join up into has_many association
      r = minimum("ifnull(quantity,0)",
                  :joins => "LEFT JOIN available_quantities " \
                            "ON availability_changes.id = available_quantities.availability_change_id " \
                            "AND available_quantities.group_id = #{group.id}",
                  :conditions => [ "inventory_pool_id = ? " \
                                   "AND model_id = ? " \
                                   "AND availability_changes.date BETWEEN ? AND ? " \
                                   "AND available_quantities.status_const = ?",
                                   inventory_pool.id, model.id, start_date, end_date, state ] )
      
      max_per_group[group.name] = r.to_i;                                   
    end

#    return 0 if none_available_in_that_state?(model, inventory_pool, start_date, end_date, state)
#
#    available_quantities = AvailabilityChange.find( :conditions => [ "date BETWEEN ? AND ?", start_date, end_date ])
#     
#    periods.each do |period|
#      if period.is_part_of?(start_date, end_date) || period.encloses?(start_date, end_date) || period.start_date_in?(start_date, end_date) || period.end_date_in?(start_date, end_date)
#        maximum_available = period.quantity if period.quantity < maximum_available
#      end
#    end
#    maximum_available

     return max_per_group
  end

#  def none_available_in_that_state?(model, inventory_pool, start_date, end_date, state)
#    available_quantities = AvailabilityChange.count(find( :conditions => [ "date BETWEEN ? AND ?", start_date, end_date ])
#  end

end
