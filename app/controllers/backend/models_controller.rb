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
            for_current_inventory_pool = params[:for_current_inventory_pool],
            with = params[:with] ? params[:with].deep_symbolize_keys : {} )

    respond_to do |format|
      format.html
      format.json {
        models = Model
                  .select("DISTINCT models.*")
                  .search(query, [:name])
                  .order("#{sort_attr} #{sort_dir}")
        if for_current_inventory_pool
          models = models.where(:id => current_inventory_pool.models)
        end
        if category_id
          models = models.joins(:categories).where(:"model_groups.id" => [Category.find(category_id)] + Category.find(category_id).descendants)
        end
        models = (models)
                   .sort{|a,b| a.name.strip <=> b.name.strip}
                   .paginate(:page => page, :per_page => per_page)
        hash = { entries: view_context.hash_for(models, with),
                 pagination: {
                    current_page: models.current_page,
                    per_page: models.per_page,
                    total_pages: models.total_pages,
                    total_entries: models.total_entries
                  }
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
    ActiveRecord::Base.transaction do
      not_authorized! unless is_privileged_user? # TODO before_filter for :create
      respond_to do |format|
        format.json {

          @model = Model.create(name: params[:model][:name])

          # accessories
          params[:model][:accessories_attributes].each_pair do |k, v|
            m = v.delete(:active) ? :inventory_pool_ids_add : :inventory_pool_ids_remove
            v[m] = current_inventory_pool.id
          end if params[:model][:accessories_attributes]
          # packages
          packages = params[:model].delete(:packages)
          if packages
            @model.is_package = true
            update_packages packages
          end
          # compatibles
          if params[:model].has_key? :compatibles_attributes
            @compatibles = params[:model].delete(:compatibles_attributes)
            handle_compatibles
          end
          # categories
          if params[:model].has_key? :category_ids
            category_ids = params[:model].delete(:category_ids)    
            @model.update_attributes(:category_ids => category_ids) if category_ids
          end

          # model
          if @model.update_attributes(params[:model])
            show({:preset => :model})
          else
            render :text => @model.errors.full_messages.uniq.join(", "), :status => :bad_request
          end
        }
      end
    end
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      respond_to do |format|
        format.json {
          # accessories
          params[:model][:accessories_attributes].each_pair do |k, v|
            m = v.delete(:active) ? :inventory_pool_ids_add : :inventory_pool_ids_remove
            v[m] = current_inventory_pool.id
          end if params[:model][:accessories_attributes]
          # properties
          if params[:model].has_key?(:properties_attributes)
            @model.properties.destroy_all
          end
          # packages
          packages = params[:model].delete(:packages)
          if packages
            @model.is_package = true
            update_packages packages
          end
          # compatibles
          if params[:model].has_key? :compatibles_attributes
            @compatibles = params[:model].delete(:compatibles_attributes)
            handle_compatibles
          end
          # model
          if @model.update_attributes(params[:model])
            show({:preset => :model})
          else
            render :text => @model.errors.full_messages.uniq.join(", "), :status => :bad_request
          end
        }
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        begin @model.destroy
          render :json => true, status: :ok
        rescue ActiveRecord::DeleteRestrictionError => e
          @model.errors.add(:base, e)
          render :text => @model.errors.full_messages.uniq.join(", "), :status => :forbidden
        end
      end
    end

    #if @model and params[:id]
      #@model.compatibles.delete(@model.compatibles.find(params[:id]))
      #flash[:notice] = _("Compatible successfully removed")
      #redirect_to :action => 'index', :model_id => @model
    #end
  end

#################################################################

  def handle_compatibles
    @model.compatibles.destroy_all
    if @compatibles
      @compatibles.each do |compatible|
        @model.compatibles << Model.find_by_id(compatible[:id])
      end
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

  private #######

  def update_packages(packages)
    packages.each do |package|

      package.delete :inventory_code
      children = package.delete :children

      if package["id"].blank?
        item = Item.create(:inventory_code => "P-#{Item.proposed_inventory_code(current_inventory_pool)}",
                              :owner_id => current_inventory_pool.id,
                              :model => @model)
        children.each do |child|
          item.children << Item.find_by_id(child["id"])
        end
        flash[:notice] = "#{_("Model saved")} / #{_("Packages created")}"
      else
        item = Item.find_by_id(package["id"])
        package.delete :id
        if package["_destroy"]
          item.destroy()
          next
        elsif item
          item.children = []
          if children
            children.each do |child|
              item.children << Item.find_by_id(child["id"])
            end
          end
        end
      end

      item.update_attributes package
      item.save!
    end
  end

end
