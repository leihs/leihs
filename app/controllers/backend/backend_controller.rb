class Backend::BackendController < ApplicationController
  
  before_filter :init
  
  layout 'backend/main'
  
  def init
    @new_orders = Order.new_orders
  end
  
end
