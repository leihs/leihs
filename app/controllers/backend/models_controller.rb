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
  before_filter :only => [:new, :update] do
    not_authorized! unless is_privileged_user?
  end

######################################################################

  def index(query = params[:query],
            sort_attr = params[:sort_attr] || 'name',
            sort_dir = params[:sort_dir] || 'ASC',
            page = (params[:page] || 1).to_i,
            per_page = (params[:per_page] || PER_PAGE).to_i,
            category_id = params[:category_id].try(:to_i),
            with = params[:with] ? params[:with].deep_symbolize_keys : {} )

    respond_to do |format|
      format.html
      format.json {
        models = Model
                  .select("DISTINCT models.*")
                  .search(query, [:name])
                  .order("#{sort_attr} #{sort_dir}")
        models = (models)
                   .sort{|a,b| a.name.strip <=> b.name.strip}
                   .paginate(:page => page, :per_page => PER_PAGE)
        hash = { inventory: {
                    entries: view_context.hash_for(models, with),
                    pagination: {
                      current_page: models.current_page,
                      per_page: models.per_page,
                      total_pages: models.total_pages,
                      total_entries: models.total_entries
                    }
                  },
                } 
        
        render :json => hash
      } 
    end
  end

  def show(with = params[:with])
    respond_to do |format|
      format.json {
        with ||= {preset: params[:preset]} if params[:preset] # FIXME request nested parameters in angular
        render json: view_context.hash_for(@model, with)
      }
    end
  end

  def new
    render :action => 'edit'
  end
  
  def create
    not_authorized! unless is_privileged_user? # TODO before_filter for :create
    respond_to do |format|
      format.json {
        # TODO DRY
        params[:model][:accessories_attributes].each_pair do |k, v|
          m = v.delete(:active) ? :inventory_pool_ids_add : :inventory_pool_ids_remove
          v[m] = current_inventory_pool.id
        end if params[:model][:accessories_attributes]

        category_ids = params[:model].delete(:category_ids)
        @model = Model.create(params[:model])
        @model.update_attributes(:category_ids => category_ids) if category_ids

        if @model.valid?
          show({:preset => :model})
        else
          render :text => @model.errors.full_messages.uniq.join(", "), :status => :bad_request
        end
      }
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      format.json {
        # TODO DRY
        params[:model][:accessories_attributes].each_pair do |k, v|
          m = v.delete(:active) ? :inventory_pool_ids_add : :inventory_pool_ids_remove
          v[m] = current_inventory_pool.id
        end if params[:model][:accessories_attributes]

        if @model.update_attributes(params[:model])
          show({:preset => :model})
        else
          render :text => @model.errors.full_messages.uniq.join(", "), :status => :bad_request
        end
      }
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

  def set_group_partition
    @model.partitions.set_in(current_inventory_pool, params[:groups])
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

    flash[:error] = m.errors.full_messages.uniq unless m.save
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

#################################################################

  def timeline
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

end
