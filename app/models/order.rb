class Order < ActiveRecord::Base

  belongs_to :user
  has_many :order_lines

  NEW = 'new'
  APPROVED = "approved"

  def self.new_orders
    find(:all, :conditions => {:status => Order::NEW})
  end


  def add(quantity, type)
    o = OrderLine.new(:quantity => quantity, 
                      :order_id => id, 
                      :type_id => type.id)
                  
    order_lines << o
  end
  
end
