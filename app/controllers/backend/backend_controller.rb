class Backend::BackendController < ApplicationController
  
  before_filter :init
  
  layout 'backend/00-patterns/general' # 'backend/main'
  $layout_public_path = "/layouts/00-patterns"
    
  def init
    @new_orders = Order.new_orders
  end
  
end
