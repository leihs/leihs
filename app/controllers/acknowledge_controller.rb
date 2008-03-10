class AcknowledgeController < ApplicationController
  
  def index
    flash[:notice] = "hello"
    @new_orders = Order.new_orders
  end
  
end
