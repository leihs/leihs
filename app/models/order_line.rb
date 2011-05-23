# == Schema Information
#
# Table name: order_lines
#
#  id                :integer(4)      not null, primary key
#  model_id          :integer(4)
#  order_id          :integer(4)
#  inventory_pool_id :integer(4)
#  quantity          :integer(4)      default(1)
#  start_date        :date
#  end_date          :date
#  created_at        :datetime
#  updated_at        :datetime
#

class OrderLine < DocumentLine

  belongs_to :order
  belongs_to :inventory_pool
  belongs_to :model  

  validates_presence_of :order
  validate :validates_inventory_pool

  before_save :assign_inventory_pool

  scope :submitted,   :joins => :order,
                            :conditions => ["orders.status_const = ?", Order::SUBMITTED]
  scope :unsubmitted, :joins => :order,
                            :conditions => ["orders.status_const = ?", Order::UNSUBMITTED]                          
  scope :running,     lambda { |date|
                                     { :conditions => ["end_date >= ?", date] }
                                   }
  scope :by_user,     lambda { |user|
                                     { :joins => :order,
                                       :conditions => {:orders => {:user_id => user}} }
                                   }

###############################################

  def is_late?(current_date = Date.today)
    false #TODO 27 Not necessary anymore
  end

  def document
    order
  end
  
  def item
    nil
  end

###############################################

  private
  
  # OPTIMIZE suggest best possible inventory pool according to the other order_lines
  # TODO 08** in case of backend add_line, make sure is assigned to current_inventory_pool
  def assign_inventory_pool
    if self.inventory_pool.nil?
      inventory_pool = nil
      inventory_pools = model.inventory_pools #temp# & order.user.inventory_pools # TODO 08** also scope to the selected frontend inventory_pools ?? 
      inventory_pools.each do |ip|
         if ip.items.count(:conditions => {:model_id => model.id}) >= quantity
           inventory_pool = ip
           break
         end
      end
      self.inventory_pool = inventory_pool
    end
  end

  def validates_inventory_pool
    # TODO ?? model.inventory_pools.include?(order.inventory_pool)
    errors.add_to_base(_("Inconsistent Inventory Pool")) if order.status_const != 1 and inventory_pool_id != order.inventory_pool_id
  end
  
end

