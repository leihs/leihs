class OrdersController < FrontendController

  before_filter :pre_load

#  def index
#    @orders = current_user.orders
#  end
  
  def new
    render :nothing => true
  end

  def submit
    @order.created_at = DateTime.now
    if @order.submit(params[:purpose])
      # TODO 18** List Inventory Pools ... and additional informations
      render :text => _("The order has been successfully submitted, but is NOT YET CONFIRMED."), :status => 200
    else
      render :nothing => true, :status => 400
    end
  end

  def add_line(model_id = params[:model_id],
               model_group_id = params[:model_group_id],
               user_id = params[:user_id] || current_user.id, # OPTIMIZE
               quantity = params[:quantity] || 1,
               start_date = params[:start_date],
               end_date = params[:end_date],
               inventory_pool_id = params[:inventory_pool_id] )
    if model_group_id
      model = ModelGroup.find(model_group_id) # TODO add templates
    else
      model = current_user.models.find(model_id)
    end

    if start_date
      sd = start_date.split('.').map{|x| x.to_i}
      start_date = Date.new(sd[2],sd[1],sd[0])
    end
    if end_date
      ed = end_date.split('.').map{|x| x.to_i}
      end_date = Date.new(ed[2],ed[1],ed[0])
    end

    inventory_pool = (inventory_pool_id ? current_user.inventory_pools.find(inventory_pool_id) : nil)
    
    model.add_to_document(@order, user_id, quantity, start_date, end_date, inventory_pool)
    
    flash[:notice] = _("Line couldn't be added") unless @order.save
    
#    render :nothing => true # render :text => ""
    render :text => @order.errors.full_messages.to_s, :status => (@order.errors.empty? ? 200 : 400)
  end

  def remove_lines
    if request.post?
      lines = @order.lines.find(params[:lines].split(','))
      lines.each {|l| @order.remove_line(l, current_user.id) }
    end
    render :nothing => true
  end  

  # change quantity for a given line
  def change_line(line_id = params[:order_line_id],
                  required_quantity = params[:quantity].to_i)
    if request.post? 
      @order_line = OrderLine.find(line_id)
      @order = @order_line.order

      @order_line, @change = @order.update_line(@order_line.id, required_quantity, current_user.id)
      @maximum_exceeded = required_quantity != @order_line.quantity
      @order.save
      
      render :nothing => true
    end
  end

  # change time frame for OrderLines or ContractLines 
  def change_time_lines(lines = @order.lines.find(params[:lines].split(',')),
                        start_date = params[:start_date].split('.').map{|x| x.to_i},
                        end_date = params[:end_date].split('.').map{|x| x.to_i} )
    if request.post?
        sd = Date.new(start_date[2],start_date[1],start_date[0])
        ed = Date.new(end_date[2],end_date[1],end_date[0])
        order = current_user.get_current_order
        lines.each {|l| order.update_time_line(l, sd, ed, current_user.id) }
        
        render :text => order.errors.full_messages.to_s, :status => (order.errors.empty? ? 200 : 400)
#        if order.errors.empty?
#          render :text => ""
#        else
#          render :json => order.errors.full_messages.to_ext_json(:success => false)
#        end
    end   
  end      

########################################################

  def show(sort =  params[:sort] || "model", dir =  params[:dir] || "ASC")
    order = current_user.get_current_order
    respond_to do |format|
#      format.ext_json { render :json => order.order_lines.sort{|x,y| x.send(sort) <=> y.send(sort) }.to_ext_json(:include => :model, :methods => :available?) }
      format.ext_json { render :json => order.to_json(:methods => :approvable?,
                                                      :include => {
                                                          :order_lines => { :include => {:model => {},
                                                                                         :inventory_pool => {:except => [:description,
                                                                                                                         :logo_url,
                                                                                                                         :contract_url,
                                                                                                                         :contract_description],
                                                                                                              :methods => [:closed_days, 
                                                                                                                           :closed_dates] } },
                                                                            :methods => :available?,
                                                                            :except => [:created_at, :updated_at]}
                                                          } ) }
    end
  end

########################################################
  

  private
  
  def pre_load
      # TODO
      #if params[:id]
      #  @order = Order.find(params[:id], :conditions => { :status_const => Order::NEW })
      #else
        @order = current_user.get_current_order
      #end
    #rescue
    #  redirect_to :action => 'index' unless @order
  end  
end
