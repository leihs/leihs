class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    with = { :inventory_pool_id => current_inventory_pool.id }
    with[:user_id] = @user.id if @user
    
    if not params[:year].blank? and params[:month].blank?
      with[:created_at] = Date.new(params[:year].to_i).to_time.to_i..Date.new(params[:year].to_i).end_of_year.to_time.to_i
    elsif not params[:month].blank?
      with[:created_at] = Date.new(params[:year].to_i, params[:month].to_i).beginning_of_month.to_time.to_i..Date.new(params[:year].to_i, params[:month].to_i).end_of_month.to_time.to_i
    end
    
    scope = case params[:filter]
              when "approved"
                :sphinx_approved
              when "rejected"
                :sphinx_rejected
              when "pending"
                :sphinx_submitted
              else
                :sphinx_all
            end
    
    @entries = Order.send(scope).search params[:query], { :star => true, :page => params[:page], :per_page => $per_page, :with => with, :sort_mode => :extended, :order => "status_const ASC, created_at ASC" }
    @pages = @entries.total_entries/$per_page
    
    @total_entries = (Order.send(scope).search nil, { :star => true, :page => 1, :per_page => 1, :with => with }).total_entries
    
    @available_months = []
    unless params[:year].blank?
      for month in 1..12
         with[:created_at] = Date.new(params[:year].to_i, month).beginning_of_month.to_time.to_i..Date.new(params[:year].to_i, month).end_of_month.to_time.to_i
         search_for_month = Array(Order.send(scope).search params[:query], { :star => true, :page => 1, :per_page => 1, :with => with}).first
         @available_months << month unless search_for_month.blank?
      end
    end
      
    first_order = Array(Order.send(scope).search params[:query], { :star => true, :page => 1, :per_page => 1, :with => with, :sort_mode => :extended, :order => "created_at ASC" }).first
    @first_date = first_order.blank? ? nil : first_order.created_at
    last_order = Array(Order.send(scope).search params[:query], { :star => true, :page => 1, :per_page => 1, :with => with, :sort_mode => :extended, :order => "created_at DESC" }).first
    @last_date = last_order.blank? ? nil : last_order.created_at
    
    
    respond_to do |format|
      format.html
    end
  end

  def show
  end
  
  private ##################################################################
  
  def preload
    params[:order_id] ||= params[:id] if params[:id]
    @order = current_inventory_pool.orders.find(params[:order_id]) if params[:order_id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
