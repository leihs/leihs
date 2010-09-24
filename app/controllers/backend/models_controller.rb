class Backend::ModelsController < Backend::BackendController

  before_filter :pre_load
  before_filter :authorized_privileged_user?, :only => [:new, :update]

  def index
    # OPTIMIZE 0501
    params[:sort] ||= 'name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    with = {}
    search_scope = Model
    case params[:filter]
      when "all"
      when "own"
        with[:unretired_owner_id] = current_inventory_pool.id
      else
        with[:unretired_inventory_pool_id] = current_inventory_pool.id
    end

    search_scope = search_scope.sphinx_packages unless params[:packages].blank?
    with[:compatible_id] = @model.id if @model
    with[:category_id] = @category.self_and_all_child_ids if @category
    with[:sphinx_internal_id] = @group.models.collect(&:id) if @group
    
    search_scope = search_scope.sphinx_with_unpackaged_items(current_inventory_pool.id) if params[:source_path]
    
    @models = search_scope.search params[:query], { :index => "model",
                                                    :star => true, :page => params[:page], :per_page => $per_page,
                                                    :with => with,
                                                    :order => params[:sort], :sort_mode => params[:sort_mode] }

    if params[:source_path] # we are in a greybox
      if @line # this is for swap model
        @start_date = @line.start_date
        @end_date = @line.end_date
        @user = @line.document.user            
      else # this is for add new model
        @start_date = Date.parse(params[:start_date])
        @end_date = Date.parse(params[:end_date])
        @user = current_inventory_pool.users.find(params[:user_id])
      end
    end

    @show_categories_tree = (@category.nil? and params[:packages].blank?)

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@models) }
      format.auto_complete { render :layout => false }
    end
  end

  def show
   # redirect_to :action => 'package', :layout => params[:layout] if @model.is_package?

    @changes = @model.availability_changes.in(current_inventory_pool).recompute_if_empty
  end

  def new
    @model = Model.new
    render :action => 'details'
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
      redirect_to details_backend_inventory_pool_model_path(current_inventory_pool, @model)
    else
      flash[:error] = _("Couldn't update ")
      render :action => 'details' # TODO 24** redirect to the correct tabbed form
    end
  end

  # only for destroying compatibles (the "compatible" route maps to this models controller)
  # at this moment models are *never* allowed to being destroyed from the GUI
  def destroy 
    if @model and params[:id]
        @model.compatibles.delete(@model.compatibles.find(params[:id]))
        flash[:notice] = _("Compatible successfully removed")
        redirect_to :action => 'index', :model_id => @model
    end
  end
  
#################################################################

  def details
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
      redirect_to package_backend_inventory_pool_model_path(current_inventory_pool, @model, :filter => params[:filter])
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

  #2408#
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
                    when "own", "own_items"
                      current_inventory_pool.own_items.scoped_by_model_id(@model)
                    else
                      current_inventory_pool.items.scoped_by_model_id(@model)
                  end
  end

  def new_package_root
    m = @model.items.build(:inventory_code => "P-#{Item.proposed_inventory_code(current_inventory_pool)}",
                           :inventory_pool => current_inventory_pool,
                           :is_borrowable => true)

    flash[:error] = m.errors.full_messages unless m.save
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
      @item.save # forcing delta index
    end
    get_root_items
    render :action => 'package_roots'
  end

#################################################################

  def properties
    if request.post?
      # TODO 0408** Rails 2.3: accepts_nested_attributes_for
      @model.properties.destroy_all
      params[:properties].delete_if {|p| p[:key].blank? or p[:value].blank? }
      @model.properties.create(params[:properties])
      @model.touch
      flash[:notice] = _("The properties have been updated.")
    end
    # TODO 0408** scope @model.categories
    @properties_set = Model.with_properties.collect{|m| m.properties.collect(&:key)}.uniq
  end

#############################################################

  def categories
    if request.post?
      @model.add_category(@category)
      flash[:notice] = _("Model is now in category %s") % @category.name
      render :update do |page|
        page.replace_html 'flash', flash_content
      end
    elsif request.delete?
      @model.remove_category(@category)
      flash[:notice] = _("Model is not in category %s now") % @category.name
      render :update do |page|
        page.replace_html 'flash', flash_content
      end
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

  def attachments
    if request.post?
      @attachment = Attachment.new(params[:attachment])
      @attachment.model = @model
      if @attachment.save
        flash[:notice] = _("Attachment was successfully created.")
      else
        flash[:error] = _("Upload error.")
      end
    elsif request.delete?
      @model.attachments.destroy(params[:attachment_id])
    end
  end

#############################################################

  def set_group_partition
    @model.availability_changes.in(current_inventory_pool).recompute(params[:groups])
    flash[:notice] = _("The group quantities were successfully saved.")
    redirect_to :action => :show
  end

#################################################################

  private

  def pre_load
    params[:model_id] ||= params[:id] if params[:id]

    @model = Model.find(params[:model_id]) if params[:model_id]

    @category = Category.find(params[:category_id]) if not params[:category_id].blank? and params[:category_id].to_i != 0

    if params[:item_id]
      @item = current_inventory_pool.items.first(:conditions => {:id => params[:item_id]})
      @item ||= current_inventory_pool.own_items.first(:conditions => {:id => params[:item_id]}) #, :retired => :all
    end
    
    @group = current_inventory_pool.groups.find(params[:group_id]) if params[:group_id]
    
    @model = @item.model if @item and !@model
    @line = current_inventory_pool.contract_lines.find(params[:contract_line_id]) if params[:contract_line_id]
    @line = current_inventory_pool.order_lines.find(params[:order_line_id]) if params[:order_line_id]
    
    @tabs = []
    @tabs << :category_backend if @category
    @tabs << :model_backend if @model
    @tabs << :group_backend if @group

  end

end
