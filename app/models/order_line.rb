class OrderLine < DocumentLine

  belongs_to :order
  
  has_many :options


  
  def self.current_reservations(model_id, date = Date.today)
    find(:all, :conditions => ['model_id = ? and start_date < ? and end_date > ?', model_id, date, date])
  end
  
  def self.future_reservations(model_id, date = Date.today)
    find(:all, :conditions => ['model_id = ? and start_date > ?', model_id, date])
  end
  
  def self.current_and_future_reservations(model_id, order_line_id = 0, date = Date.today)
    find(:all, :conditions => ['model_id = ? and ((start_date < ? and end_date > ?) or start_date > ?) and id <> ?', model_id, date, date, date, order_line_id])
  end

  def order_to_exclude
    id
  end
  
  def contract_to_exclude
    0
  end
  
#working#
#  # OPTIMIZE provide spreading to multiple inventory pools  
#  def possible_inventory_pools
#    ip_set = []
#    # TODO check availability
#    model.inventory_pools.each do |ip|
#      ip_set << ip if ip.items.count(:conditions => {:model_id => model.id}) >= quantity
#    end
#    ip_set
#  end

  # TODO temp check, remove it 
  def correct_inventory_pool?
    model.inventory_pools.any?{|ip| ip == order.inventory_pool }
  end
  
end
