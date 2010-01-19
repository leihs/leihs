class Backend::ModelsController < Backend::BackendController

  before_filter :pre_load
  before_filter :authorized_privileged_user?, :only => [:new, :update]

  def index
    # OPTIMIZE 0501
    params[:sort] ||= 'name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    case params[:filter]
      when "own"
        models = current_inventory_pool.own_models_active
      when "all"
        models = Model.all
      else
        models = current_inventory_pool.models_active
    end

    # OPTIMIZE
    models = models.packages unless params[:packages].blank?

    models &= @model.compatibles if @model
    models &= @category.all_models if @category
    
    @models = models.search(params[:query], { :star => true,
                                              :page => params[:page],
                                              :per_page => $per_page,
                                              :order => params[:sort],
                                              :sort_mode => params[:sort_mode] } )
    
    # we are in a greybox
    if params[:source_path]

      if @line
        @start_date = @line.start_date
        @end_date = @line.end_date
        @user = @line.document.user            
      else
        @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today
        @end_date = params[:end_date] ? Date.parse(params[:end_date]) : @start_date + 2.days
        @user = current_inventory_pool.users.find(params[:user_id])
      end

      # TODO 2702** use named_scope instead
      # OPTIMIZE 2702** total_entries counter
      @models.delete(@line.model) if @line
      models_to_delete = []
      @models.each do |model|
          max_available = model.maximum_available_in_period_for_inventory_pool(@start_date, @end_date, current_inventory_pool, @user)
          
          if max_available > 0
            model.write_attribute(:max_available, max_available)
          else
            models_to_delete << model
          end
      end
      models_to_delete.each do |model|
        @models.delete(model)
      end

    end #if

    @show_categories_tree = (@category.nil? and (not request.xml_http_request?) and params[:packages].blank?)

    respond_to do |format|
      format.html
      format.auto_complete { render :layout => false }
    end
  end

  def show
   # redirect_to :action => 'package', :layout => params[:layout] if @model.is_package?
  end

  def new
    @model = Model.new
    render :action => 'show'
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
    else
      authorized_privileged_user? # TODO before_filter for :create
      @model = Model.new
      update
    end
  end

  def update
    if @model.update_attributes(params[:model])
      redirect_to backend_inventory_pool_model_path(current_inventory_pool, @model)
    else
      flash[:error] = _("Couldn't update ")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
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
# Packages

  def package
    new_package_root if @model.items.empty?
  end

  def new_package
    @model = Model.new
    render :action => 'package'
  end

  def update_package
    @model ||= Model.first(:conditions => ['name = ?', params[:model][:name]])
    @model ||= Model.new(:is_package => true)
    if not @model.is_package?
      flash[:error] = _("The selected model is not a package")
      return
    end
    
    if @model.update_attributes(params[:model])
      flash[:notice] = _("Package successfully saved")
      redirect_to package_backend_inventory_pool_model_path(current_inventory_pool, @model)
    else
      flash[:error] = _("Error saving the package")
      render :action => 'package'
    end
  end
  
  def destroy_package
    if @model.destroy
      flash[:notice] = _("Package successfully destroyed")
    else
      flash[:error] = _("Error destroying the package")
    end
    redirect_to backend_inventory_pool_models_path(current_inventory_pool, :packages => true)
  end

  def package_roots
    if request.put?
      if @model.items.find(params[:root_id]).update_attributes(:inventory_code => params[:inventory_code])
        flash[:notice] = _("Inventory code updated")
      else
        flash[:error] = _("Error updating inventory code")
      end
    elsif request.delete?
      if @model.items.find(params[:root_id]).destroy
        flash[:notice] = _("Item package successfully destroyed")
      else
        flash[:error] = _("Error destroying the item package")
      end
    elsif request.post?
      new_package_root
    end

    get_root_items
  end
  
  def get_root_items
        @root_items = case params[:filter]
                    when "own"
                      current_inventory_pool.own_items.by_model(@model)
                    else
                      current_inventory_pool.items.by_model(@model)
                  end
  end

  def new_package_root
    ip_name = current_inventory_pool.shortname ? current_inventory_pool.shortname : current_inventory_pool.name
    @model.items.create(:inventory_code => "P-#{ip_name}#{Item.proposed_inventory_code}",
                        :inventory_pool => current_inventory_pool,
                        :is_borrowable => true)
  end

  def package_item
    root_item = @model.items.find(params[:root_id]) 
    if request.put?
      if @item.model.is_package?
        flash[:error] = _("You can't add a package to a package.")
      else
        root_item.children << @item
      end
    elsif request.delete?
      root_item.children.delete(@item)
    end
    get_root_items
    render :action => 'package_roots'
  end

#################################################################

  def properties
    if request.post?
        # TODO 0408** Rails 2.3: accepts_nested_attributes_for
        @model.properties.destroy_all
        @model.properties.create(params[:properties])
        flash[:notice] = _("The properties have been updated.")
    end
    # TODO 0408** scope @model.categories
    @properties_set = Model.with_properties.collect{|m| m.properties.collect(&:key)}.uniq
  end

#############################################################

  def categories
    if request.post?
      unless @category.models.include?(@model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink
        @category.models << @model
        flash[:notice] = _("Category successfully assigned")
      else
        flash[:error] = _("The model is already assigned to this category")
      end
      render :nothing => true # TODO render flash
    elsif request.delete?
      @category.models.delete(@model)
      flash[:notice] = _("Category successfully removed")
      render :nothing => true # TODO render flash
    else
      @categories = @model.categories
    end
  end


#################################################################

  def accessories
    if request.put?
      current_inventory_pool.accessories -= @model.accessories
      current_inventory_pool.accessories << @model.accessories.find(params[:accessory_ids]) if params[:accessory_ids]
      flash[:notice] = _("Successfully set.")
      redirect_to
    elsif request.post?
      accessory = @model.accessories.build(:name => params[:name])
      if accessory.save
        flash[:notice] = _("The accessory was successfully created.")
      else
        flash[:error] = _("Error creating the accessory.")
      end
      redirect_to
    elsif request.delete?
      if @model.accessories.delete(@model.accessories.find(params[:accessory_id]))
        flash[:notice] = _("The accessory was successfully deleted.")
      else
        flash[:error] = _("Error deleting the accessory.")
      end
      redirect_to
    end
  end
  
  
  
#################################################################

  def images
    if request.post?
      @image = Image.new(params[:image])
      @image.model = @model
      if @image.save
        flash[:notice] = _("Attachment was successfully created.")
      else
        flash[:error] = _("Upload error.")
      end
    elsif request.delete?
      @model.images.destroy(params[:image_id])
    end
  end

#################################################################

  private

  def pre_load
    params[:model_id] ||= params[:id] if params[:id]

    @model = Model.find(params[:model_id]) if params[:model_id]

    @category = Category.find(params[:category_id]) if not params[:category_id].blank? and params[:category_id].to_i != 0

    @item = current_inventory_pool.items.find(params[:item_id]) if params[:item_id]
    @model = @item.model if @item and !@model
    @line = current_inventory_pool.contract_lines.find(params[:contract_line_id]) if params[:contract_line_id]
    @line = current_inventory_pool.order_lines.find(params[:order_line_id]) if params[:order_line_id]
    
    @tabs = []
    @tabs << :category_backend if @category
    @tabs << :model_backend if @model

  end

end
