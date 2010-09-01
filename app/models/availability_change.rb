class AvailabilityChange < ActiveRecord::Base
  belongs_to :inventory_pool
  belongs_to :model
  has_many :available_quantities, :dependent => :destroy

  validates_presence_of :inventory_pool_id
  validates_presence_of :model_id
  validates_presence_of :date

  validates_uniqueness_of :date, :scope => [:inventory_pool_id, :model_id]

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
    #old# TODO keep manager definition and delete others 
    #model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).all(:conditions => ["date != ?", Date.parse("2010-01-01")]).each {|x| x.destroy } # OPTIMIZE
    #changes = [model.availability_changes.defined_for_inventory_pool(inventory_pool)]
    
    #changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool) # TODO filter out past changes ??
    #changes << model.availability_changes.new_current_for_inventory_pool(inventory_pool) if changes.blank?

#tmp#
#    changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool)
#    changes << model.availability_changes.reset_for_inventory_pool(inventory_pool) if changes.blank?
    
    reservations = model.running_reservations(inventory_pool)
    reservations.each do |document_line|
#tmp#      groups = document_line.document.user.groups.scoped_by_inventory_pool_id(inventory_pool) & changes.first.available_quantities.collect(&:group)
      recompute_reservation(document_line) #tmp#, groups)
    end
  end

  def self.recompute_reservation(document_line) #tmp#, groups)
    # OPTIMIZE
    model = document_line.model
    inventory_pool = document_line.inventory_pool
    group_found = false

    #tmp#
    groups = document_line.document.user.groups.scoped_by_inventory_pool_id(inventory_pool)
    
    maximum = maximum_available_in_period(model, inventory_pool, groups, document_line.start_date, document_line.end_date)
    # TODO sort groups by quantity desc
    groups.each do |group|
      if maximum[group.name] >= document_line.quantity
        clone_change(model, inventory_pool, document_line.start_date).save
        
        # OPTIMIZE increment .tomorrow is not needed if already exists
        inner_changes = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).all(:conditions => {:date => (document_line.start_date..document_line.end_date.tomorrow)})
        inner_changes.each do |ic|
          a = ic.available_quantities.scoped_by_group_id(group).first
          a.decrement(:in_quantity).increment(:out_quantity).add_document(document_line).save
        end
        
        c = clone_change(model, inventory_pool, document_line.end_date.tomorrow)
        a = c.available_quantities.scoped_by_group_id(group).first
        # OPTIMIZE decrement .tomorrow is not needed if already exists
        a.increment(:in_quantity).decrement(:out_quantity).remove_document(document_line).save
        
        group_found = true
        break
      end
    end

    unless group_found
      clone_change(model, inventory_pool, document_line.start_date).save
      clone_change(model, inventory_pool, document_line.end_date.tomorrow).save
    end
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
    #tmp# inventory_pool.items.borrowable.in_stock.scoped_by_model_id(model).count
    inventory_pool.items.borrowable.scoped_by_model_id(model).count - borrowable_not_in_stock_total
  end

  def borrowable_not_in_stock
    # TODO named_scope
    model.contract_lines.by_inventory_pool(inventory_pool).all(:conditions => ["start_date <= ? AND end_date >= ? AND returned_date IS NULL", date, date])
  end
  
  def borrowable_not_in_stock_total
    #tmp# inventory_pool.items.borrowable.not_in_stock.scoped_by_model_id(model).count
    #temp# model.running_reservations(inventory_pool, date).count
    borrowable_not_in_stock.count
  end

  def general_borrowable_size
    inventory_pool.items.borrowable.scoped_by_model_id(model).count - available_quantities.sum(:in_quantity).to_i - available_quantities.sum(:out_quantity).to_i
  end

  def general_borrowable_in_stock_size
    borrowable_in_stock_total - available_quantities.sum(:in_quantity).to_i
  end

  def general_borrowable_not_in_stock_size
    borrowable_not_in_stock_total - available_quantities.sum(:out_quantity).to_i
  end

  def general_borrowable_not_in_stock
    documents = available_quantities.collect(&:documents).flatten.compact
    borrowable_not_in_stock.collect {|d| {:type => d.class.to_s, :id => d.id} } - documents
  end
  
  def total_in_group(group)
    # TODO one single query values("SUM(...) + SUM()")
    #available_quantities.scoped_by_group_id(group).sum(:in_quantity).to_i + available_quantities.scoped_by_group_id(group).sum(:out_quantity).to_i
    q = available_quantities.scoped_by_group_id(group).first
    (q ? q.in_quantity + q.out_quantity : 0)
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
  def self.maximum_available_in_period(model, inventory_pool, group_or_groups, start_date, end_date)
    # start from most recent entry we have, which is the last before start_date
    start_date = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).maximum(:date, :conditions => [ "date <= ?", start_date ]) \
                 || start_date.to_date
    
    end_date = end_date.to_date
    tmp_end_date = model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).minimum(:date, :conditions => [ "date >= ?", start_date ])
    end_date = [tmp_end_date, end_date].max if tmp_end_date

    max_per_group = Hash.new
    Array(group_or_groups).each do |group|
      # we don't save AvailableQuantities for Groups that have zero vailable Models for space efficiency
      # reasons thus when there's an AvailabilityChange and there's no associates AvailabilityQuantity
      # then we know it's zero. So if there are more AvailabilityChanges than associated
      # AvailableQuantities then we know there are some that are null
      # TODO: move join up into has_many association
      r = minimum("ifnull(in_quantity,0)",
                  :joins => "LEFT JOIN available_quantities " \
                            "ON availability_changes.id = available_quantities.availability_change_id " \
                            "AND available_quantities.group_id = #{group.id}",
                  :conditions => [ "inventory_pool_id = ? " \
                                   "AND model_id = ? " \
                                   "AND availability_changes.date BETWEEN ? AND ?",
                                   inventory_pool.id, model.id, start_date, end_date ] )

      max_per_group[group.name] = r.to_i
    end


    return max_per_group
  end


end
