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
            borrower_user = params[:user_id].try{|x| current_inventory_pool.users.find(x)},
            borrowable = (params[:borrowable] ? !(params[:borrowable] == "false") : nil),
            retired = (params[:retired] == "true" ? true : nil),
            item_filter = params[:filter],
            start_date = params[:start_date].try{|x| Date.parse(x)},
            end_date = params[:end_date].try{|x| Date.parse(x)},
            responsibles = (params[:responsibles] == "true" ? true : nil),
            with = params[:with] ? params[:with].deep_symbolize_keys : {} )
    
    if request.format == :json or request.format == :csv

        scoped_items = if retired
          Item.unscoped.where(Item.arel_table[:retired].not_eq(nil))
        else
          Item # NOTE using default scope, that is {retired => nil}
        end.by_owner_or_responsible(current_inventory_pool)

        scoped_items = scoped_items.send(borrowable ? :borrowable : :unborrowable) if not borrowable.nil? 
    
        unless item_filter.nil?
          if item_filter[:flags]
            [:in_stock, :incomplete, :broken].each do |k|
              scoped_items = scoped_items.send(k) if item_filter[:flags].include?(k.to_s)
            end
            scoped_items = scoped_items.where(:owner_id => current_inventory_pool) if item_filter[:flags].include?(:owned.to_s)
          end
          scoped_items = scoped_items.where(:inventory_pool_id => item_filter[:responsible_id]) if item_filter[:responsible_id]
        end 
         
        options = if borrowable != false and retired.nil? and item_filter.nil?
          current_inventory_pool.options.search(query, [:name]).order("#{sort_attr} #{sort_dir}")
        else
          []
        end
    end

    respond_to do |format|
      format.html
      format.json {
        item_ids = scoped_items.select("items.id")
        models = Model #tmp# show all models ?? # .joins(:items).where("items.id IN (#{item_ids.to_sql})")
                  .select("DISTINCT models.*")
                  .search(query, [:name, :items])
                  .order("#{sort_attr} #{sort_dir}")
        # TODO migrate strip directly to the database, and strip on before_validation
        models_and_options = (models + options)
                             .sort{|a,b| a.name.strip <=> b.name.strip}
                             .paginate(:page => page, :per_page => PER_PAGE)
        with.deep_merge!({ :items => {:scoped_ids => item_ids, :query => query} })  
        hash = { inventory: {
                    entries: view_context.hash_for(models_and_options, with),
                    pagination: {
                      current_page: models_and_options.current_page,
                      per_page: models_and_options.per_page,
                      total_pages: models_and_options.total_pages,
                      total_entries: models_and_options.total_entries
                    }
                  },
                } 
        
        if responsibles
          responsibles_for_items = InventoryPool.joins(:items).where("items.id IN (#{item_ids.to_sql})").select("DISTINCT inventory_pools.*")
          hash.merge!({responsibles: view_context.hash_for(responsibles_for_items)})
        end
        
        render :json => hash
      } 
      format.csv {
        require 'csv'
        items = scoped_items.search(query)
        csv_string = CSV.generate({ :col_sep => ";", :quote_char => "\"", :force_quotes => true }) do |csv|
          csv << Item.csv_header
          items.each do |i|
            csv << i.to_csv_array unless i.nil? # How could an item ever be nil?
          end
          options.each do |o|
            csv << o.to_csv_array unless o.nil? # How could an item ever be nil?
          end
        end
       
        send_data csv_string, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=#{_("Items-leihs")}.csv"
      }
    end
  end

  def show
    respond_to do |format|
      format.json {
        render json: view_context.hash_for(@model, {:is_editable => true,
                                                    :description => true,
                                                    :technical_detail => true,
                                                    :internal_description => true,
                                                    :hand_over_note => true,
                                                    :images => {},
                                                    :attachments => {},
                                                    :accessories => {}})
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

        @model = Model.new(params[:model])
        if @model.save
          show
        else
          render :text => @model.errors.full_messages.uniq.join(", "), :status => :bad_request
        end
      }
    end
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
          show
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

#################################################################

  def timeline
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

end
