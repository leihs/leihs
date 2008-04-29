class Backend::BackendController < ApplicationController
  
  before_filter :init
  
  $theme = '00-patterns'
  $modal_layout_path = 'backend/' + $theme + '/modal'
  $general_layout_path = 'backend/' + $theme + '/general'
  $layout_public_path = "/layouts/00-patterns"
  
  layout $general_layout_path
  
  def init
    @new_orders = Order.new_orders
    #TODO define session[:user_id]
  end
  
end
