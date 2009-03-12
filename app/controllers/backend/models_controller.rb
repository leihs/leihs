class Backend::ModelsController < Backend::BackendController

  before_filter :pre_load

  def index
    params[:sort] ||= 'models.name'
    params[:dir] ||= 'ASC'

    models = current_inventory_pool.models

    models = models & @model.compatibles if @model

    case params[:filter]
      when "packages"
        models = models.packages
    end

    if params[:category_id] and params[:category_id].to_i != 0
      category = Category.find(params[:category_id].to_i)
      models = models & (category.children.recursive.to_a << category).collect(&:models).flatten
    end
    
    @models = models.search(params[:query], {:page => params[:page], :per_page => $per_page}, {:order => sanitize_order(params[:sort], params[:dir])})
    
    # we are in a greybox
    if params[:source_path]

      if @line
        @start_date = @line.start_date
        @end_date = @line.end_date
        @user = @line.document.user            
      else
        @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today
        @end_date = params[:end_date] ? Date.parse(params[:end_date]) : @start_date + 2.days
        @user = current_user
      end
  
      # TODO 2702** use named_scope instead
      # OPTIMIZE 2702** total_entries counter
      @models.delete(@line.model) if @line
      @models.each do |model|
          max_available = model.maximum_available_in_period_for_inventory_pool(@start_date, @end_date, current_inventory_pool, @user)
          
          if max_available > 0
            model.write_attribute(:max_available, max_available)
          else
            @models.delete(model)
          end
      end
    end

    @show_categories_tree = !(request.xml_http_request? or params[:filter] == "packages")
  end

  def show
    redirect_to :action => 'package', :layout => params[:layout] if @model.is_package?
  end
  
  def create
    if @model and params[:compatible][:model_id]
      @compatible_model = current_inventory_pool.models.find(params[:compatible][:model_id])
      unless @model.compatibles.include?(@compatible_model)
        @model.compatibles << @compatible_model
        flash[:notice] = _("Model successfully added as compatible")
      else
        flash[:error] = _("The model is already compatible")
      end
      redirect_to :action => 'index', :model_id => @model
    end
  end

  def destroy
    if @model and params[:id]
        @model.compatibles.delete(@model.compatibles.find(params[:id]))
        flash[:notice] = _("Compatible successfully removed")
        redirect_to :action => 'index', :model_id => @model
    end
  end
  
#################################################################

  # TODO 04** refactor in a dedicated controller?

  def package 
  end

  def new_package
    @model = Model.new
    render :action => 'package' #, :layout => false
  end

  def update_package(name = params[:name], inventory_code = params[:inventory_code])
    @model ||= Model.new
    @model.is_package = true
    @model.name = name
    @model.save 
    @model.items.create(:location => current_inventory_pool.main_location) if @model.items.empty?
    @model.items.first.update_attribute(:inventory_code, inventory_code)
    redirect_to :action => 'package', :id => @model
  end

  def package_items
  end

  def add_package_item
    # OPTIMIZE 03** @model.package_items << @item
    @model.items.first.children << @item
    redirect_to :action => 'package_items', :id => @model
  end

  def remove_package_item
    # OPTIMIZE 03** @model.package_items.delete(@item)
    @model.items.first.children.delete(@item)
    redirect_to :action => 'package_items', :id => @model
  end

  def package_location
    if request.post?
      @model.items.first.update_attribute(:location, current_inventory_pool.locations.find(params[:location_id]))
      redirect_to
    end
  end

#################################################################

# TODO 29** where is still needed?
  def available_items
#old#    
#    a_items = current_inventory_pool.items.all(:conditions => ["model_id IN (?) AND inventory_code LIKE ?",
#                                                                params[:model_ids],
#                                                                '%' + params[:code] + '%'])
#    @items = a_items.select {|i| i.in_stock? }

    # OPTIMIZE check availability
    
    @items = current_inventory_pool.items.in_stock.all(:conditions => ["model_id IN (?) AND inventory_code LIKE ?",
                                                                        params[:model_ids],
                                                                        '%' + params[:code] + '%'])
    
    render :inline => "<%= auto_complete_result(@items, :inventory_code) %>"
  end
  
#################################################################

  def properties
  end

#################################################################

  def accessories
    if request.post?
      @current_inventory_pool.accessories -= @model.accessories
      
      (params[:accessory_ids] || []).each do |a|
        @current_inventory_pool.accessories << @model.accessories.find(a.to_i)
      end
      redirect_to
    end
  end
  
#################################################################

  def images
  end

#################################################################

# TODO 0203** temp
#  def chart
#    render :inline => "<tr><td colspan='6'><%= canvas_for(@model) %></td></tr>"
#  end

#################################################################

  private
  
  def pre_load
    params[:model_id] ||= params[:id] if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]
    @item = current_inventory_pool.items.find(params[:item_id]) if params[:item_id]
    @model = @item.model if @item and !@model
    @line = current_inventory_pool.contract_lines.find(params[:contract_line_id]) if params[:contract_line_id]
    @line = current_inventory_pool.order_lines.find(params[:order_line_id]) if params[:order_line_id]
    
    @tabs = []
    @tabs << (@model.is_package ? :package_backend : :model_backend ) if @model
  end

end
