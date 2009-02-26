class Backend::HandOverController < Backend::BackendController

  before_filter :pre_load

  def index
    visits = current_inventory_pool.hand_over_visits
    
    unless params[:query].blank?
      @contracts = current_inventory_pool.contracts.new_contracts.search(params[:query])

      # OPTIMIZE display only effective visits (i.e. for a given model name, ...)
      visits = visits.select {|v| v.contract_lines.any? {|l| @contracts.include?(l.contract) } } # OPTIMIZE named_scope intersection?
    end

    visits = visits.select {|v| v.user == @user} if @user # OPTIMIZE named_scope intersection?
    
    @visits = visits.paginate :page => params[:page], :per_page => $per_page
  end

  # get current open contract for a given user
  def show
  end
  
  def delete_visit
    params[:lines].each {|l| @contract.remove_line(l, current_user.id) }
    redirect_to :action => 'index'
  end
  
  # Sign definitely the contract
  def sign_contract
    @lines = @contract.contract_lines.find(params[:lines].split(',')) if params[:lines]
    @lines ||= []
    if request.post?
      @contract.sign(@lines)
      render :action => 'print_contract', :layout => $modal_layout_path
    else
      @lines = @lines.delete_if {|l| l.item.nil? }
      flash[:error] = _("No items to hand over specified. Please assign inventory codes to the items you want to hand over.") if @lines.empty?
      render :layout => $modal_layout_path
    end    
  end

  # Changes the line according to the inserted inventory code
  def change_line
    if request.post?
      # TODO refactor in the Contract model and keep track of changes

      @contract_line = current_inventory_pool.contract_lines.find(params[:contract_line_id])
      @contract = @contract_line.contract
      
      required_item_inventory_code = params[:code]
      @contract_line.item = Item.first(:conditions => { :inventory_code => required_item_inventory_code})
      @contract_line.start_date = Date.today
      @contract_line.end_date = Date.today if @contract_line.end_date < @contract_line.start_date
      #old# @start_date_changed = @contract_line.start_date_changed?
      flash[:notice] = _("The start date has been changed") if @contract_line.start_date_changed? # TODO 1102** still not sure the @contract_line will be saved after validation!

      if @contract_line.save
        # TODO refactor in model: change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{line.start_date} - #{line.end_date}" }
        # TODO refactor in model: log_change(change, user_id)
      else
        @contract_line.errors.each_full do |msg|
          @contract.errors.add_to_base msg
        end
        flash[:error] = @contract.errors.full_messages
      end
    end
  end  

  # given an inventory_code, searches for a matching contract_line
  # and if not found, adds an option
  def assign_inventory_code
    item = current_inventory_pool.items.first(:conditions => { :inventory_code => params[:code] })
    
    unless item.nil?
      if @contract.items.include?(item)
          flash[:error] = _("The item is already in the current contract.")
      else
        contract_line = @contract.contract_lines.first(:conditions => { :model_id => item.model.id, :item_id => nil })
        unless contract_line.nil?
          params[:contract_line_id] = contract_line.id.to_s
          flash[:notice] = _("Inventory Code assigned")
          if item.required_level > current_user.level_for(item.inventory_pool)
            flash[:error] = _("This item requires the user to be level %s") % item.required_level.to_s
          end
          change_line
        else
          @new_item = item
        end
      end
    else 
      # Inventory Code is not an item - might be an option...
      # Increment quantity if the option is already present
      option = current_inventory_pool.options.first(:conditions => { :inventory_code => params[:code] })
      if option
        @option_line = @contract.option_lines.find_or_create_by_option_id(:option_id => option, :quantity => 0)
        @option_line.update_attribute :quantity, @option_line.quantity + 1
        flash[:notice] = _("Option %s added.") % option.name
      else
        flash[:error] = _("The Inventory Code %s was not found.") % params[:code]
      end   
    end
    
    render :action => 'change_line' unless @prevent_redirect # TODO 29**
  end

  def add_option
    if request.post?
      option = current_inventory_pool.options.find(params[:option_id])
      @contract.option_lines.create(:option => option, :quantity => 1)
      redirect_to :action => 'show', :id => @contract
    else
      redirect_to :controller => 'options', 
                  :layout => 'modal',
                  :source_path => request.env['REQUEST_URI']
    end
  end

  # TODO 29**
  def add_line_with_item
    @prevent_redirect = true
    item = current_inventory_pool.items.find(params[:item_id])
    params[:model_id] = item.model.id
    add_line
    params[:code] = item.inventory_code
    assign_inventory_code
    redirect_to :action => 'show'
  end

  def add_line
    generic_add_line(@contract)
  end

  def swap_model_line
    generic_swap_model_line(@contract)
  end

  def time_lines
    generic_time_lines(@contract)
  end    

  # remove a contract line for a given contract
  def remove_lines
    generic_remove_lines(@contract)
  end  

  def timeline
    @timeline_xml = @contract.timeline
    render :nothing => true, :layout => 'backend/' + $theme + '/modal_timeline'
  end
  
  def select_location
    @lines = @contract.contract_lines.find(params[:lines].split(','))
    @location = Location.new
    if request.post? and not (params[:location][:building].blank? and params[:location][:building].blank?)
      @location = Location.find(:first, :conditions => {:building => params[:location][:building], :room => params[:location][:room]})
      unless @location
        @location = Location.create(params[:location])
        @location.inventory_pool = current_inventory_pool
      end
      @lines.each do |line|
        line.location = @location
        line.save  
      end
    end
    
    if request.delete?
      @lines.each do |line|
        line.location = nil
        line.save
      end
    end
    render :layout => 'backend/' + $theme + '/modal'
  end
    
  def auto_complete_for_location_building
    @locations = Location.all(:conditions => ['building LIKE ?', params[:location][:building] + "%"])
    @field = "building"
    render :inline => "<%= auto_complete_result(@locations, :building) %>"
  end
  
  def auto_complete_for_location_room
    @locations = Location.all(:conditions => ['room LIKE ?', params[:location][:room] + "%"])
    @field = "room"
    render :inline => "<%= auto_complete_result(@locations, :room) %>"
  end
  
  private
  
  def pre_load
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
    @contract = @user.get_current_contract(current_inventory_pool) if @user
  end


end
