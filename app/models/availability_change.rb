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
    changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool) # TODO filter out past changes ??
    changes << model.availability_changes.new_current_for_inventory_pool(inventory_pool) if changes.blank?
    
    reservations = model.running_reservations(inventory_pool)
    reservations.each do |r|
      groups = r.document.user.groups.scoped_by_inventory_pool_id(inventory_pool) & changes.first.available_quantities.collect(&:group)
      # TODO sort groups by quantity desc
      maximum = maximum_available_in_period(model, inventory_pool, groups, r.start_date, r.end_date)
      groups.each do |g|
        if maximum[g.name] >= r.quantity
          clone_change(model, inventory_pool, r.start_date).save
          
          inner_changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).all(:conditions => {:date => (r.start_date..r.end_date)})
          inner_changes.each do |ic|
            ic.available_quantities.scoped_by_group_id(g).first.decrement(:available_quantity).increment(:unavailable_quantity).add_document(r).save
          end
          
          c = clone_change(model, inventory_pool, r.end_date)
          c.available_quantities.scoped_by_group_id(g).first.increment(:available_quantity).decrement(:unavailable_quantity).remove_document(r).save
          
          break
        end
      end
    end
    
    # TODO compact on dates
  end
  
  def self.clone_change(model, inventory_pool, date)
    # OPTIMIZE
    c = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).last(:conditions => ["date <= ?", date])
    c ||= model.availability_changes.current_for_inventory_pool(inventory_pool)
 
    if c.date != date
      g = c.clone
      g.date = date
      c.available_quantities.each {|q| g.available_quantities << q.clone }
      g.save
      c = g
    end
    c
  end

#############################################

  def borrowable_in_stock_total
    inventory_pool.items.borrowable.in_stock.scoped_by_model_id(model).count
    #tmp# inventory_pool.items.borrowable.scoped_by_model_id(model).count - borrowable_not_in_stock_total
  end

  def borrowable_not_in_stock_total
    #tmp# inventory_pool.items.borrowable.not_in_stock.scoped_by_model_id(model).count
    model.running_reservations(inventory_pool, date).count
  end

  def unborrowable_in_stock_total
    inventory_pool.items.unborrowable.in_stock.scoped_by_model_id(model).count
  end

  def unborrowable_not_in_stock_total
    inventory_pool.items.unborrowable.not_in_stock.scoped_by_model_id(model).count
  end


  def general_borrowable_size
    inventory_pool.items.borrowable.scoped_by_model_id(model).count - available_quantities.sum(:available_quantity).to_i - available_quantities.sum(:unavailable_quantity).to_i
  end

  def general_borrowable_in_stock_size
    borrowable_in_stock_total - available_quantities.sum(:available_quantity).to_i
  end

  def general_borrowable_not_in_stock_size
    borrowable_not_in_stock_total - available_quantities.sum(:unavailable_quantity).to_i
  end
  
  def total_in_group(group)
    # TODO one single query values("SUM(...) + SUM()")
    available_quantities.scoped_by_group_id(group).sum(:available_quantity).to_i + available_quantities.scoped_by_group_id(group).sum(:unavailable_quantity).to_i
  end

#############################################

#old#
#  def self.maximum_available_in_period(model, inventory_pool, group_or_groups, start_date, end_date)
#    maximum_in_state_in_period(model, inventory_pool, group_or_groups, start_date, end_date, AvailableQuantity::AVAILABLE)
#  end
#
#  def self.maximum_borrowed_in_period(model, inventory_pool, group_or_groups, start_date, end_date)
#    maximum_in_state_in_period(model, inventory_pool, group_or_groups, start_date, end_date, AvailableQuantity::BORROWED)
#  end
#
#  def self.maximum_borrowed_in_period(model, inventory_pool, group_or_groups, start_date, end_date)
#    maximum_in_state_in_period(model, inventory_pool, group_or_groups, start_date, end_date, AvailableQuantity::UNBORROWABLE)
#  end

  # how many items of #Model in a 'state' are there at most over the given period?
  #
  # returns a hash à la: { 'General' => 4, 'CAST' => 2, ... }
  #
#old#  def self.maximum_in_state_in_period(model, inventory_pool, groups, start_date, end_date, state)
  def self.maximum_available_in_period(model, inventory_pool, groups, start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date
    # start from most recent entry we have, which is the last before start_date
    start_date = AvailabilityChange.maximum(:date, :conditions => [ "date <= ?", start_date ]) \
                 || start_date

    max_per_group = Hash.new
    Array(groups).each do |group|
      # we don't save AvailableQuantities for Groups that have zero vailable Models for space efficiency
      # reasons thus when there's an AvailabilityChange and there's no associates AvailabilityQuantity
      # then we know it's zero. So if there are more AvailabilityChanges than associated
      # AvailableQuantities then we know there are some that are null
      # TODO: move join up into has_many association
      r = minimum("ifnull(available_quantity,0)",
                  :joins => "LEFT JOIN available_quantities " \
                            "ON availability_changes.id = available_quantities.availability_change_id " \
                            "AND available_quantities.group_id = #{group.id}",
                  :conditions => [ "inventory_pool_id = ? " \
                                   "AND model_id = ? " \
                                   "AND availability_changes.date BETWEEN ? AND ?",
                                   inventory_pool.id, model.id, start_date, end_date ] )
      
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
