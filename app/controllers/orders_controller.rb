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
    if request.post? and @order.submit(params[:purpose])
      
      redirect_to '/'
    else
      render :layout => $modal_layout_path
    end        
  end

  def add_line
    if params[:model_group_id]
      model = ModelGroup.find(params[:model_group_id]) # TODO add templates
    else
      model = current_user.models.find(params[:model_id])
    end
    params[:user_id] ||= current_user.id # OPTIMIZE
    params[:quantity] ||= 1
    model.add_to_document(@order, params[:user_id], params[:quantity])
    
    flash[:notice] = _("Line couldn't be added") unless @order.save
#    if request.xml_http_request?
#      render :action => 'basket', :layout => false
      render :nothing => true # render :text => ""
#    else
#      redirect_to :action => 'new', :id => @order.id        
#    end
  end

  def remove_lines
    lines = @order.lines.find(params[:lines].split(','))
    lines.each {|l| @order.remove_line(l, current_user.id) }      
    render :nothing => true
  end  

  # change quantity for a given line
  def change_line(line_id = params[:order_line_id],
                  required_quantity = params[:quantity].to_i)
 #   if request.post?
      @order_line = OrderLine.find(line_id)
      @order = @order_line.order

      @order_line, @change = @order.update_line(@order_line.id, required_quantity, current_user.id)
      @maximum_exceeded = required_quantity != @order_line.quantity
      @order.save
      
      render :nothing => true
#    end
end

  # change time frame for OrderLines or ContractLines 
  def change_time_lines(order_line_id = params[:order_line_id],
                        start_date = params[:start_date].split('-').map{|x| x.to_i},
                        end_date = params[:end_date].split('-').map{|x| x.to_i} )
#    if request.post?
        sd = Date.new(start_date[0],start_date[1],start_date[2])
        ed = Date.new(end_date[0],end_date[1],end_date[2])
        line = OrderLine.find(order_line_id)
        document = current_user.orders.find(line.order.id) # scoping for user
        document.update_time_line(line.id, sd, ed, current_user.id)
        
        render :text => document.errors.full_messages.to_s, :status => (document.errors.empty? ? 202 : 403)
#        if document.errors.empty?
#          render :text => ""
#        else
#          render :json => document.errors.full_messages.to_ext_json(:success => false)
#        end
#    end   
  end      

########################################################

  def show(sort =  params[:sort] || "model", dir =  params[:dir] || "ASC")
    order = current_user.get_current_order
    respond_to do |format|
#      format.ext_json { render :json => order.order_lines.sort{|x,y| x.send(sort) <=> y.send(sort) }.to_ext_json(:include => :model, :methods => :available?) }
      format.ext_json { render :json => order.to_json(:include => {
                                                          :order_lines => { :include => {:model => {},
                                                                                         :inventory_pool => {:except => [:description,
                                                                                                                         :logo_url,
                                                                                                                         :contract_url,
                                                                                                                         :contract_description]} },
                                                                            :methods => :available?,
                                                                            :except => [:created_at, :updated_at]}
                                                          } ) }
    end
  end

########################################################
  

  private
  
  def pre_load
      # OPTIMIZE
      if params[:id]
        @order = Order.find(params[:id], :conditions => { :status_const => Order::NEW })
      else
        @order = current_user.get_current_order
      end
    rescue
      redirect_to :action => 'index' unless @order
  end  
end
