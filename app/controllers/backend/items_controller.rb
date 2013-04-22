class Backend::ItemsController < Backend::BackendController
  
  before_filter do
    params[:id] ||= params[:item_id] if params[:item_id]
    
    conditions = if params[:id]
      {:id => params[:id]}
    elsif params[:inventory_code]
      {:inventory_code => params[:inventory_code]}
    end

    @item = if conditions
      current_inventory_pool.items.where(conditions).first ||
      Item.unscoped { current_inventory_pool.own_items.where(conditions).first }
    end
    
    @model = if @item
                @item.model
             elsif params[:model_id]
                Model.find(params[:model_id])
             end
  end

######################################################################
  
  def index(with = params[:with])
    items = if @model
      current_inventory_pool.items.in_stock.scoped_by_model_id @model
    else
      current_inventory_pool.items
    end
    respond_to do |format|
      format.json { render :json => view_context.json_for(items, with) }
    end
  end

  def new
    @item = Item.new(:owner => current_inventory_pool)
    @item.inventory_code = Item.proposed_inventory_code(current_inventory_pool)
    if @current_user.access_level_for(current_inventory_pool) < 2
      @item.inventory_pool = current_inventory_pool
    end
    @item.is_inventory_relevant = (is_super_user? ? true : false)
  end
 
  def create
    @item = Item.new(:owner => current_inventory_pool)

    Field.all.each do |field|
      next unless field.permissions
      if field.get_value_from_params params[:item]
        unless field.editable current_user, current_inventory_pool, @item
          @item.errors.add(:base, _("You are not the owner of this item")+", "+_("therefore you may not be able to change some of these fields"))
        end
      end
    end
    unless @item.errors.any?
      saved = @item.update_attributes(params[:item])
    end

    respond_to do |format|
      format.json {
        if saved
          render(:status => :ok, json: view_context.json_for(@item, {preset: :item_edit}))
        else
          if @item
            render :text => @item.errors.full_messages.uniq.join(", "), :status => :bad_request
          else
            render :json => {}, :status => :not_found
          end
        end
      }
      format.html {
        if saved
          if params[:copy]
            redirect_to copy_backend_inventory_pool_item_path(current_inventory_pool, @item.id), notice: _("New item created.")
          else
            redirect_to backend_inventory_pool_inventory_path(current_inventory_pool)
          end
        else
          flash[:error] = @item.errors.full_messages.uniq
          redirect_to new_backend_inventory_pool_item_path(current_inventory_pool)
        end
      }
    end
  end

  def update
    if @item
      # check permissions by checking flexible field permissions
      Field.all.each do |field|
        next unless field.permissions
        if field.get_value_from_params params[:item]
          unless field.editable current_user, current_inventory_pool, @item
            @item.errors.add(:base, _("You are not the owner of this item")+", "+_("therefore you may not be able to change some of these fields"))
          end
        end
      end
      unless @item.errors.any?
        saved = @item.update_attributes(params[:item])
      end
    end

    respond_to do |format|
      format.json { 
        if saved
          render(:status => :ok, json: view_context.json_for(@item, {preset: :item_edit}))
        else
          if @item
            render :text => @item.errors.full_messages.uniq.join(", "), :status => :bad_request
          else
            render :json => {}, :status => :not_found
          end
        end
      }
      format.html {
        if saved
          if params[:copy]
            redirect_to copy_backend_inventory_pool_item_path(current_inventory_pool, @item.id), notice: _("Item saved.")
          else
            redirect_to backend_inventory_pool_inventory_path(current_inventory_pool)
          end
        else
          flash[:error] = @item.errors.full_messages.uniq
          render :action => 'show'
        end
      }
    end
  end

  def copy
    @item = @item.dup
    @item.inventory_code = Item.proposed_inventory_code(current_inventory_pool)
  end

  def find
    respond_to do |format|
      format.json { 
        if @item
          render(:json => view_context.json_for(@item))
        else
          render(:status => :not_found)
        end
      }
    end
  end
  
  def show(with = params[:with])
    respond_to do |format|
      format.json { 
        unless @item.nil?
          render(:json => view_context.json_for(@item, with))
        else
          render(:status => :unauthorized, :nothing => true)
        end
      }
      format.html { 
      if @item.nil?
        flash[:error] = _("You don't have access to this item.")
        redirect_to backend_inventory_pool_items_path(current_inventory_pool)
      else
        get_histories
      end
      }
    end
  end

  def retire
    @item.retired = Date.today
    @item.retired_reason = params[:retired_reason]

    if @item.save
      msg = _("Item retired (%s)") % @item.retired_reason
      @item.log_history(msg, current_user.id)

      respond_to do |format|
        format.json { render :json => true, :status => 200 }
      end
    else
      errors = @item.errors.full_messages.join ", "

      respond_to do |format|
        format.json { render :text => errors, :status => 500 }
      end
    end
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

#################################################################

  def notes
    if request.post?
      @item.log_history(params[:note], current_user.id)
    end
    @histories = @item.histories

    get_histories
    
    params[:layout] = "modal" #old??#
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
