class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    with = { :inventory_pool_id => current_inventory_pool.id }
    with[:user_id] = @user.id if @user
             
    scope = case params[:filter]
                when "approved"
                  :sphinx_approved
                when "rejected"
                  :sphinx_rejected
                else
                  :sphinx_submitted
              end
    
    @orders = Order.send(scope).search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                                         :with => with }

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@orders) }
    end

  end

  def show
    # TODO 13** send errors and notices
    respond_to do |format|
      if params[:template] == "value_list"
        require 'prawn/measurement_extensions'
        prawnto :prawn => { :page_size => 'A4',
                            :left_margin => 25.mm,
                            :right_margin => 15.mm,
                            :bottom_margin => 15.mm,
                            :top_margin => 15.mm
                          }
        format.pdf { send_data(render(:template => 'orders/value_list_for_models', :layout => false), :type => 'application/pdf', :filename => "value_list_#{@order.id}.pdf") }
      end

    end
  end
 
  private
  
  def preload
    params[:order_id] ||= params[:id] if params[:id]
    @order = current_inventory_pool.orders.find(params[:order_id]) if params[:order_id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
