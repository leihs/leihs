class Backend::ModelsController < Backend::BackendController
  
  before_filter do
    params[:model_id] ||= params[:id] if params[:id]

    @model = Model.find(params[:model_id]) if params[:model_id]

    @category = Category.find(params[:category_id]) if not params[:category_id].blank? and params[:category_id].to_i != 0
    @categories = Category.find(params[:category_ids]) unless params[:category_ids].blank?

    if params[:item_id]
      @item = current_inventory_pool.items.where(:id => params[:item_id]).first
      #@item ||= Item.unscoped { current_inventory_pool.own_items.where(:id => params[:item_id]).first }
      @item ||= current_inventory_pool.own_items.where(:id => params[:item_id]).first
    end
    @model ||= @item.model if @item
    
    @group = current_inventory_pool.groups.find(params[:group_id]) if params[:group_id]
    
    @line = current_inventory_pool.contract_lines.find(params[:contract_line_id]) if params[:contract_line_id]
    @line = current_inventory_pool.order_lines.find(params[:order_line_id]) if params[:order_line_id]
    @categories ||= @line.model.categories if @line and !@line.model.categories.blank?
  end
  before_filter :authorized_privileged_user?, :only => [:new, :update]

######################################################################

  def index(query = params[:query],
            sort_attr = params[:sort_attr] || 'name',
            sort_dir = params[:sort_dir] || 'ASC',
            page = (params[:page] || 1).to_i,
            per_page = (params[:page] || $per_page).to_i,
            category_id = params[:category_id].try(:to_i),
            borrower_user = params[:user_id].try{|x| current_inventory_pool.users.find(x)},
            borrowable = (params[:borrowable] ? !(params[:borrowable] == "false") : nil),
            retired = (params[:retired] == "true" ? true : nil),
            filter = params[:filter],
            start_date = params[:start_date].try{|x| Date.parse(x)},
            end_date = params[:end_date].try{|x| Date.parse(x)},
            with = params[:with])
    
    item_ids = if retired
      Item.unscoped.where(Item.arel_table[:retired].not_eq(nil))
    else
      Item # NOTE using default scope, that is {retired => nil}
    end.select("items.id").by_owner_or_responsible(current_inventory_pool)
    item_ids = item_ids.send(borrowable ? :borrowable : :unborrowable) if not borrowable.nil? 

    [:in_stock, :incomplete, :broken, :owned].each do |k|
      item_ids = item_ids.send(k) if filter.include?(k.to_s)
    end unless filter.nil? 

    models = Model.joins(:items).where("items.id IN (#{item_ids.to_sql})")
              .select("DISTINCT models.*")
              .search2(query)
              .order("#{sort_attr} #{sort_dir}")
 
    options = if borrowable != false and retired.nil?
      current_inventory_pool.options.search2(query).order("#{sort_attr} #{sort_dir}")
    else
      []
    end

    @responsibles = InventoryPool.joins(:items).where("items.id IN (#{item_ids.to_sql})").select("DISTINCT inventory_pools.*")

    # TODO migrate strip directly to the database, and strip on before_validation
    @models_and_options = (models + options)
                          .sort{|a,b| a.name.strip <=> b.name.strip}
                          .paginate(:page => page, :per_page => $per_page)

    respond_to do |format|
      format.html {
        with = { :image_thumb => true,
                 :inventory_code => true, # for options
                 :price => true, # for options
                 :is_package => true,
                 :items => {:scoped_ids => item_ids,
                            :query => query,
                            :current_borrower => true,
                            :current_return_date => true,
                            :in_stock? => true,
                            :is_broken => true,
                            :is_incomplete => true,
                            :location => true,
                            :inventory_pool => true,
                            :children => {:model => {}}
                           },
                 :availability => {:inventory_pool => current_inventory_pool},
                 :categories => {}}
        @list_json = view_context.json_for(@models_and_options, with)
      }
      format.json {
        render :json => view_context.json_for(@models_and_options, with)
      } 
    end
  end

  def show
   # redirect_to :action => 'package', :layout => params[:layout] if @model.is_package?
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

  def groups
    @availability = @model.availability_changes_in(current_inventory_pool)
    render :partial => "groups"
  end

  def set_group_partition
    @model.partitions.in(current_inventory_pool).set(params[:groups])
    flash[:notice] = _("The group quantities were successfully saved.")
    redirect_to :action => :show
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
    @model ||= Model.where(:name => params[:model][:name]).first
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
      @model.categories.delete_all
      @model.categories << @categories if @categories
      flash[:notice] = _("This model is now in %d categories") % @model.categories.count
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

end
