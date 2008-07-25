class FrontendController < ApplicationController

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

  def basket
    order = current_user.current_order
    respond_to do |format|
      format.html { render :action => 'basket', :layout => false }
      format.ext_json { render :json => order.order_lines.to_ext_json(:include => :model) }
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

############################################################################
  def add_line
      @order = current_user.get_current_order unless @order

        model = Model.find(params[:model_id])
      model.add_to_document(@order, current_user.id, 1)
      
      flash[:notice] = _("Line couldn't be added") unless @order.save
      if request.xml_http_request?
        render :action => 'basket', :layout => false
      else
        redirect_to :action => 'new', :id => @order.id        
      end
  end

  def change_line(line_id = params[:order_line_id],
                  required_quantity = params[:quantity].to_i)
 #   if request.post?
      @order_line = OrderLine.find(line_id)
      @order = @order_line.order

      @order_line, @change = @order.update_line(@order_line.id, required_quantity, session[:user_id])
      @maximum_exceeded = required_quantity != @order_line.quantity
      @order.save
      
      render :text => ""
#    end
  end
  
end
