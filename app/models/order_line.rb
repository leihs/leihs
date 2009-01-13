class OrderLine < DocumentLine

  belongs_to :order
  belongs_to :inventory_pool
  belongs_to :model # common for sibling classes  


  before_save :assign_inventory_pool

  
###############################################  
# TODO named_scope with lambda

# TODO *d* remove??  
#  def self.current_reservations(model_id, date = Date.today)
#    find(:all, :conditions => ['model_id = ? and start_date < ? and end_date > ?', model_id, date, date])
#  end
#  
#  def self.future_reservations(model_id, date = Date.today)
#    find(:all, :conditions => ['model_id = ? and start_date > ?', model_id, date])
#  end
#  
#  def self.current_and_future_reservations(model_id, order_line_id = 0, date = Date.today)
#    find(:all, :conditions => ['model_id = ? and ((start_date < ? and end_date > ?) or start_date > ?) and id <> ?', model_id, date, date, date, order_line_id])
#  end

###############################################

  def is_late?(current_date = Date.today)
    false
  end

  # TODO use as validation?
#  def correct_inventory_pool?
#    model.inventory_pools.include?(order.inventory_pool)
#  end

  def document
    order
  end

  private
  
  # OPTIMIZE suggest best possible inventory pool according to the other order_lines
  # TODO 08** in case of backend add_line, make sure is assigned to @current_inventory_pool
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
  
end
