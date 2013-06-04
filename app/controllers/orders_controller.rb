class OrdersController < FrontendController

  before_filter do
    @order = (params[:id] ? current_user.orders.find(params[:id]) : current_user.get_current_order)
  end

######################################################################

#  def index
#    @orders = current_user.orders
#  end
  
  def show
    respond_to do |format|
      format.html { @grouped_order_lines = current_user.get_current_grouped_order_lines }
      format.pdf {
        if params[:template] == "value_list"
          require 'prawn/measurement_extensions'
          prawnto :prawn => { :page_size => 'A4', 
                              :left_margin => 25.mm,
                              :right_margin => 15.mm,
                              :bottom_margin => 15.mm,
                              :top_margin => 15.mm
                            }
          send_data(render(:template => 'orders/value_list_for_models', :layout => false), :type => 'application/pdf', :filename => "value_list_#{@order.id}.pdf")
        end
      }
    end
  end


  def new
    render :nothing => true
  end  
  
###########################################################################
  
  def submit
    @order.created_at = DateTime.now
    unless @order.submit(params[:purpose])
      render :text => _("Submission failed"), :status => 400
    else
      redirect_to submitted_user_order_path(@order)
    end
  end

  def submitted
    @grouped_order_lines = OrderLine.grouped_by_inventory_pool(@order.order_lines)
  end

###########################################################################

  def add_line(model_id = params[:model_id],
               model_group_id = params[:model_group_id],
               user_id = params[:user_id] || current_user.id, # OPTIMIZE
               quantity = params[:quantity] || 1,
               start_date = params[:start_date] || Date.today,
               end_date = params[:end_date] || Date.tomorrow,
               inventory_pool_id = params[:inventory_pool_id] || nil)
    if model_group_id
      model = Template.find(model_group_id)
      inventory_pool_id ||= model.inventory_pools.first.id
    else
      model = current_user.models.find(model_id)
    end

    if start_date.is_a? String
      sd = start_date.split('.').map{|x| x.to_i}
      start_date = Date.new(sd[2],sd[1],sd[0])
    end
    if end_date.is_a? String
      ed = end_date.split('.').map{|x| x.to_i}
      end_date = Date.new(ed[2],ed[1],ed[0])
    end

    inventory_pool = (inventory_pool_id ? current_user.inventory_pools.find(inventory_pool_id) : nil)
    
    model.add_to_document(@order, user_id, quantity, start_date, end_date, inventory_pool)

    flash[:notice] = @order.errors.full_messages.uniq unless @order.save
    redirect_to backend_inventory_pool_model_path inventory_pool_id, model
  end

  def remove_lines
    # using where() instead of find() to ignore line_ids of already deleted lines 
    lines = @order.lines.where(:id => params[:lines].split(','))
    lines.each {|l| @order.remove_line(l, current_user.id) }
    render :nothing => true
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
        
        render :text => order.errors.full_messages.uniq.to_s, :status => (order.errors.empty? ? 200 : 400)
    end   
  end      

########################################################

  def destroy
    @order.destroy if @order.deletable_by_user?
    respond_to do |format|
      format.json { render :partial => "/orders/pending" }
    end
  end

end
