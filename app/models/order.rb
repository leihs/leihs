class Order < ActiveRecord::Base

  NEW = 'new'

  belongs_to :user
  
  def self.new_orders
    find(:all, :conditions => {:status => Order::NEW})
  end

end
