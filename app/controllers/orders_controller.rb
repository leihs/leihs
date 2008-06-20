class OrdersController < ApplicationController
  require_role "student"

  before_filter :load_order, :except => [:index, :new]

  def index
    redirect_to :action => 'new'
  end
  
  def new
    @order = current_user.get_current_order
  end

  def submit
    if request.post? and @order.submit
      
      #redirect_to :action => 'index'
      render :text => "order submitted"
    else
      render :layout => $modal_layout_path
    end        
  end

  # TODO merge reservation and acknowledge methods? (i.e. mixin module)
  def add_line
    if request.post?
      params[:quantity] ||= 1
      @order.add_line(params[:quantity].to_i, Model.find(params[:model_id]), params[:user_id])
      flash[:notice] = _("Model couldn't be added") unless @order.save        
      redirect_to :action => 'new', :id => @order.id        
    else
      redirect_to :controller => 'backend/models', # TODO refactor to frontend
                  :action => 'search',
                  :id => params[:id],
                  :source_controller => params[:controller],
                  :source_action => params[:action]
    end
  end

  # TODO merge reservation and acknowledge methods? (i.e. mixin module)
  # change quantity for a given line
  def change_line
    if request.post?
      @order_line = OrderLine.find(params[:order_line_id])
      @order = @order_line.order
      required_quantity = params[:quantity].to_i

      @order_line, @change = @order.update_line(@order_line.id, required_quantity, session[:user_id])
      @maximum_exceeded = required_quantity != @order_line.quantity
      @order.save
    end
  end


  private
  
  def load_order
      @order = Order.find(params[:id], :conditions => { :status_const => Order::NEW }) if params[:id]
    rescue
      redirect_to :action => 'index' unless @order
  end  
end
