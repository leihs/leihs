class Backend::BackendController < ApplicationController
  
  before_filter :init
  
  $theme = '00-patterns'
  $modal_layout_path = 'backend/' + $theme + '/modal'
  $general_layout_path = 'backend/' + $theme + '/general'
  $layout_public_path = "/layouts/00-patterns"
  
  layout $general_layout_path
  
  
  private
  
  def init
    @new_orders_size = Order.new_orders.size
    @grouped_lines_size = 999 # TODO

    #TODO define session[:user_id]
  end
  
  def set_order_to_session(order)
    session[:current_order] = { :id => order.id,
                                :user_login => order.user.login }
  end
  
  def remove_order_from_session
    session[:current_order] = nil
  end
  
end
