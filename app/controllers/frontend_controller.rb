class FrontendController < ApplicationController

  #old# prepend_before_filter :login_required
  require_role "student"

  layout 'frontend'

  def index
  end

  # TODO prevent sql injection
  def models( category_id = params[:category_id],
              start = (params[:start] || 0).to_i,
              limit = (params[:limit] || 25).to_i,
              query = params[:query],
              sort =  params[:sort] || "name",
              dir =  params[:dir] || "ASC")
    if category_id
      # OPTIMIZE intersection
      m = Category.find(category_id).models.find(:all, :offset => start, :limit => limit, :order => "#{sort} #{dir}") & current_user.models
      c = (Category.find(category_id).models & current_user.models).size
    elsif query
      m = current_user.models.find_by_contents("*" + query + "*", {:offset => start, :limit => limit, :order => "#{sort} #{dir}"})
      c = m.total_hits
    else
      m = current_user.models.find(:all, :offset => start, :limit => limit, :order => "#{sort} #{dir}")
      c = current_user.models.count(:all)
    end
    respond_to do |format|
      format.ext_json { render :json => m.to_ext_json(:count => c) }
    end
  end

#  def details(model_id = params[:id])
#    m = current_user.models.find(model_id)
#    respond_to do |format|
#      format.ext_json { render :json => m.to_ext_json(:include => :inventory_pools) } # TODO working here
#    end
#  end

  def recent_models
    m = current_user.orders.sort.collect(&:models).flatten.uniq[0,5] if current_user
    m ||= []
    respond_to do |format|
      format.ext_json { render :json => m.to_ext_json }
    end
  end

  def basket
    order = current_user.get_current_order
    respond_to do |format|
#      format.html { render :action => 'basket', :layout => false }
      #format.ext_json { render :json => order.order_lines.to_ext_json(:include => :model) }
      format.ext_json { render :json => order.to_json(:include => {
                                                          :order_lines => { :include => :model }
                                                          } ) }
    end
  end

  # TODO interesections
  def categories(id = params[:node].to_i)
    if id == 0 
#      c = Category.roots
#      c = current_user.categories.roots
      c = current_user.all_categories & Category.roots
    else
      c = current_user.categories & Category.find(id).children # TODO scope only children Category (not ModelGroup)
#      c = current_user.categories.find(id).children
#      c = current_user.all_categories.find(id).children
    end
    respond_to do |format|
      format.ext_json { render :json => c.to_json(:methods => [:text, :leaf]) } # .to_a.to_ext_json
    end
  end

  # TODO sort on model.name
  def complete_order(sort =  params[:sort] || "model", dir =  params[:dir] || "ASC")
    order = current_user.get_current_order
    respond_to do |format|
#      format.ext_json { render :json => order.order_lines.sort{|x,y| x.send(sort) <=> y.send(sort) }.to_ext_json(:include => :model, :methods => :available?) }
      format.ext_json { render :json => order.to_json(:include => {
                                                          :order_lines => { :include => :model,
                                                                            :methods => :available?,
                                                                            :except => [:created_at, :updated_at]}
                                                          } ) }
    end
  end

############################################################################
  def add_line
      @order = current_user.get_current_order #unless @order

      model = Model.find(params[:model_id])
      model.add_to_document(@order, current_user.id, 1)
      
      flash[:notice] = _("Line couldn't be added") unless @order.save
      if request.xml_http_request?
#        render :action => 'basket', :layout => false
        render :nothing => true # render :text => ""
      else
        redirect_to :action => 'new', :id => @order.id        
      end
  end

  def remove_lines
     @order = current_user.get_current_order #unless @order
     
     lines = @order.lines.find(params[:lines].split(','))
     lines.each {|l| @order.remove_line(l, current_user.id) }
      
     render :nothing => true
  end   
  
  def change_line(line_id = params[:order_line_id],
                  required_quantity = params[:quantity].to_i)
 #   if request.post?
      @order_line = OrderLine.find(line_id)
      @order = @order_line.order

      @order_line, @change = @order.update_line(@order_line.id, required_quantity, session[:user_id])
      @maximum_exceeded = required_quantity != @order_line.quantity
      @order.save
      
      render :nothing => true # render :text => ""
#    end
  end

  # change time frame for OrderLines or ContractLines 
  def change_time_lines(order_line_id = params[:order_line_id], start_date = params[:start_date].split('-').map{|x| x.to_i}, end_date = params[:end_date].split('-').map{|x| x.to_i} )
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
  
end
