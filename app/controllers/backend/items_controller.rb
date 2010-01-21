class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load

  def index
    # OPTIMIZE 0501 
    params[:sort] ||= 'model_name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    retired = false # TODO 0501

    if params[:model_id]
      @model = Model.find(params[:model_id])
      items = (current_inventory_pool.items.by_model(@model) + current_inventory_pool.own_items.by_model(@model)).uniq # TODO current_inventory_pool.all_items.by_model(@model)
    elsif @location
      items = current_inventory_pool.items.by_location(@location)
    else
      items = current_inventory_pool.items
    end    

    case params[:filter]
      when "retired"
        items = current_inventory_pool.own_items.all(:retired => true)
        retired = true # TODO 0501
      when "responsible"
        items = (current_inventory_pool.items - current_inventory_pool.own_items)
      when "own_items"
        items = current_inventory_pool.own_items
      when "inventory_relevant"
        items = current_inventory_pool.own_items.inventory_relevant
      when "not_inventory_relevant"
        items = current_inventory_pool.own_items.not_inventory_relevant
      when "unallocated"
        items = current_inventory_pool.own_items.unallocated
      else        
        filter = params[:filter].to_sym
        filters = Item.scopes.keys #['in_stock', 'not_in_stock', 'broken', 'incomplete', 'unborrowable']
        items = items.send(filter) if filters.include?(filter)
    end if params[:filter]

    items.delete_if {|i| not i.packageable? } if request.format == :auto_complete # OPTIMIZE use params[:filter] == "packageable"
    
    @items = items.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                            :with => {:retired => retired}, # TODO 0501 default_sphinx_scope
                                            :order => params[:sort], :sort_mode => params[:sort_mode],
                                            :include => [:model, :location]}

    respond_to do |format|
      format.html
      format.auto_complete { render :layout => false }
    end
  end

  def new(id = params[:original_id])
    if id.blank?
      @item = Item.new
      @item.model = @model if @model
    else 
      @item = Item.find(id).clone
      @item.serial_number = nil
    end
    @proposed_inventory_code = Item.proposed_inventory_code
    @item.inventory_code = "#{current_inventory_pool.shortname}#{@proposed_inventory_code}"
    @item.owner = current_inventory_pool
    @item.invoice_date = Date.yesterday
    if @current_user.access_level_for(current_inventory_pool) < 2
      @item.is_inventory_relevant = false
      @item.inventory_pool = current_inventory_pool
    end
    render :action => 'show'
  end

  def create
    @item = Item.new(:owner => current_inventory_pool)
    flash[:notice] = _("New item created.")
    update
  end
    
  def update
    @item.step = params[:item][:step]
    @item.attributes = params[:item]
    
    get_histories
    
    if @item.save
      @item.update_attributes(:location => Location.find_or_create(params[:location]))
      
      if params[:copy].blank?      
        redirect_to backend_inventory_pool_item_path(current_inventory_pool, @item)
      else 
        redirect_to :action => 'new', :original_id => @item.id  
      end
      flash[:notice] = _("Item saved.") unless flash[:notice]
    else
      flash[:error] = @item.errors.full_messages
      render :action => 'show'
    end
  end

  
  def show
    get_histories
  end

#################################################################

  def location
    if request.post? or request.put?
      if @item.update_attributes(:location => Location.find_or_create(params[:location]))
        flash[:notice] = _("Location successfully set")
      else
        flash[:error] = _("Error setting the location")
      end
    end
      @item.location ||= Location.new
  end

#################################################################

  def status
  end

#################################################################

  def toggle_permission
    if request.post?
      @item.needs_permission = (not @item.needs_permission?)
      @item.save
    end
    redirect_to :action => 'show', :id => @item.id
  end

  def retire
    if request.post?
      # NOTE since it's a switch form, the hidden param ensures the correct action
      if @item.retired and !params[:retired].blank?
        @item.retired = nil
      else
        @item.retired = Date.today
      end
      @item.retired_reason = params[:reason]
      @item.log_history(_("Item retired (%s)") % @item.retired_reason, current_user)
      @item.save
      redirect_to :action => 'index'
    else
      render :action => 'retire', :layout => $empty_layout_path
    end
  end

  
#################################################################

  def notes
    if request.post?
      @item.log_history(params[:note], current_user.id)
    end
    @histories = @item.histories

    get_histories
    
    params[:layout] = "modal" 
  end

  def get_notes
    get_histories
    render :partial => 'notes', :object => @histories
  end
  
  def supplier
    if request.post? and params[:supplier]
      s = Supplier.create(params[:supplier])
      search_term = s.name
    end
    if request.post? and (params[:search] || search_term)
      search_term ||= params[:search][:name]
      @results = Supplier.all(:conditions => ['name like ?', "%#{search_term}%"], :order => :name)
    end
    render :layout => false
  end
  
#################################################################


  private

  def get_histories
    @histories = @item.histories
    @item.contract_lines.collect(&:contract).uniq.each do |contract|
      @histories += contract.actions
    end
    @item.contract_lines.each do |cl|
      @histories << History.new(:created_at => cl.start_date, :user => cl.contract.user, :text => _("Item handed over as part of contract %d.") % cl.contract.id) if cl.start_date
      @histories << History.new(:created_at => cl.end_date, :user => cl.contract.user, :text => _("Expected to be returned.")) unless cl.returned_date
    end
  end
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = current_inventory_pool.items.first(:conditions => {:id => params[:id]}) if params[:id]
    @item ||= current_inventory_pool.own_items.first(:conditions => {:id => params[:id]}, :retired => :all) if params[:id]
    
    @location = Location.find(params[:location_id]) if params[:location_id]
    
    @model = if @item
                @item.model
             elsif params[:model_id]
                Model.find(params[:model_id])
             end
  
    @tabs = []
    @tabs << :model_backend if @model and not ["new", "show"].include?(action_name)

  end

end
