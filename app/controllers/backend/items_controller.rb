class Backend::ItemsController < Backend::BackendController
  
  before_filter do
    params[:id] ||= params[:item_id] if params[:item_id]
    if params[:id]
      @item = current_inventory_pool.items.where(:id => params[:id]).first
      @item ||= Item.unscoped { current_inventory_pool.own_items.where(:id => params[:id]).first }
    end

    @location = Location.find(params[:location_id]) if params[:location_id]
    
    @model = if @item
                @item.model
             elsif params[:model_id]
                Model.find(params[:model_id])
             end
  end

######################################################################

  def index
=begin
    # OPTIMIZE 0501 
    params[:sort] ||= 'model_name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    with = {:retired => false}
#    without = {}
    
    if params[:model_id]
      sphinx_select = "*, inventory_pool_id = #{current_inventory_pool.id} OR owner_id = #{current_inventory_pool.id} AS a"
      with.merge!(:model_id => @model.id, :a => true)
    elsif params[:allocated_inventory_pool_id]
      with.merge!(:inventory_pool_id => params[:allocated_inventory_pool_id])
    elsif @location
      with.merge!(:location_id => @location.id, :inventory_pool_id => current_inventory_pool.id)
    end    

    case params[:filter]
      when "retired"
        with.merge!(:owner_id => current_inventory_pool.id, :retired => true)
      when "own_items", "own", "all"
        with.merge!(:owner_id => current_inventory_pool.id)
      when "inventory_relevant"
        with.merge!(:owner_id => current_inventory_pool.id, :is_inventory_relevant => true)
      when "not_inventory_relevant"
        with.merge!(:owner_id => current_inventory_pool.id, :is_inventory_relevant => false)
      when "unallocated"
        with.merge!(:owner_id => current_inventory_pool.id, :inventory_pool_id => 0)
#      when "responsible"
###        items = (current_inventory_pool.items - current_inventory_pool.own_items)
#        with.merge!(:inventory_pool_id => current_inventory_pool.id)
#        without.merge!(:owner_id => current_inventory_pool.id)
      when "in_stock"
        with.merge!(:inventory_pool_id => current_inventory_pool.id, :not_in_stock => false)
      when "broken"
        with.merge!(:inventory_pool_id => current_inventory_pool.id, :is_broken => true)
      when "incomplete"
        with.merge!(:inventory_pool_id => current_inventory_pool.id, :is_incomplete => true)
      when "unborrowable"
        with.merge!(:inventory_pool_id => current_inventory_pool.id, :is_borrowable => false)
      else
        with.merge!(:inventory_pool_id => current_inventory_pool.id)
    end

    with.merge!(:parent_id => 0, :model_is_package => 0) if request.format == :auto_complete # OPTIMIZE use params[:filter] == "packageable"
    
    if params[:format] == 'csv'
      page = nil
      per_page = Item.count
    else
      page = params[:page]
      per_page = $per_page
    end

    search_options = { :star => true, :page => page, :per_page => per_page,
                       :sphinx_select => sphinx_select,
                       :with => with, #:without => without,
                       :order => params[:sort], :sort_mode => params[:sort_mode],
                       :include => { :model => nil,
                                     :location => :building,
                                     :parent => :model } }    
    
    # OPTIMIZE
    @items = if params[:filter] == "retired"
      search_options[:per_page] = (2**30)
      #no-sphinx# 
      Item.unscoped { Item.where(:id => Item.search_for_ids(params[:query], search_options)) }.paginate(:per_page => per_page)
    else
      #no-sphinx#
      Item.search(params[:query], search_options)
    end

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@items) }
      format.auto_complete { render :layout => false }
      
      format.csv do
       csv_string = FasterCSV.generate({ :col_sep => ";", :quote_char => "\"", :force_quotes => true }) do |csv|
         csv << Item.csv_header
         @items.each do |i|
           csv << i.to_csv_array unless i.nil? # How could an item ever be nil?
         end
       end
       
       send_data csv_string,
                :type => 'text/csv; charset=utf-8; header=present',
                :disposition => "attachment; filename=leihs_items.csv"
      end
      
    end
=end
  end

  def new(id = params[:original_id])
    if id.blank?
      @item = Item.new
      @item.model = @model if @model
      @item.invoice_date = Date.yesterday
    else 
      @item = Item.find(id).clone
      @item.serial_number = nil
      @item.name = nil
    end
    @item.inventory_code = Item.proposed_inventory_code(current_inventory_pool)
    @item.owner = current_inventory_pool
    if @current_user.access_level_for(current_inventory_pool) < 2
      @item.inventory_pool = current_inventory_pool
    end
    @item.is_inventory_relevant = (is_super_user? ? true : false)
    render :action => 'show'
  end

  def create
    @item = Item.new(:owner => current_inventory_pool)
    flash[:notice] = _("New item created.")
    update
  end

  # TODO: we do not check here who is allowed to do what - i.e. a level 1 manager can
  #       update items directly through the backend - even though the frontend wouldn't let him
  def update
    get_histories

    params[:item][:location] = Location.find_or_create(params[:location])

# TODO: Move to before_save, this never fires this way, but in before_save we are lacking
# a current_user
#     if @item.inventory_pool_id_changed?
#       @item.log_history(_("Item %s moved responsible department from %s to %s") % 
#                         [@item, InventoryPool.find(@item.inventory_pool_id_was), @item.inventory_pool],
#                         current_user)
#     end
#     
#     if @item.owner_id_changed?
#       @item.log_history(_("Item %s moved owner from %s to %s") % 
#                         [@item, InventoryPool.find(@item.owner_id_was), @item.owner],
#                         current_user)
#     end
    

    if @item.update_attributes(params[:item])
 
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
    if @item.nil?
      flash[:error] = _("You don't have access to this item.")
      redirect_to backend_inventory_pool_items_path(current_inventory_pool)
    else
      get_histories
    end
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
      if @item.save
        msg = _("Item retired (%s)") % @item.retired_reason
        @item.log_history(msg, current_user)
        flash[:notice] = msg
        redirect_to params[:source_path] and return
      else
        flash[:error] = @item.errors.full_messages
      end
    end
    
    params[:layout] = "modal"
    render :action => 'retire'
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
      @results = Supplier.where(['name like ?', "%#{search_term}%"]).order(:name)
    end
    render :layout => false
  end

  def inventory_codes
    @free_ranges = Item.free_inventory_code_ranges(params)
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
    @histories.sort!
  end
  
end
