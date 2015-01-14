class Manage::ItemsController < Manage::ApplicationController

  def index
    @items = Item.filter params, current_inventory_pool
    set_pagination_header(@items) unless params[:paginate] == "false"
  end

  def current_locations
    items = Item.filter params, current_inventory_pool
    @locations = []
    items.each do |item|
      @locations.push({id: item.id, location: item.current_location})
    end
  end

  def new
    @type = params[:type] ? params[:type] : "item"
    @item = Item.new(:owner => current_inventory_pool)
    @item.inventory_code = Item.proposed_inventory_code(current_inventory_pool)
    unless @current_user.has_role?(:lending_manager, current_inventory_pool)
      @item.inventory_pool = current_inventory_pool
    end
    @item.is_inventory_relevant = (is_super_user? ? true : false)
  end

  def edit
    fetch_item_by_id
  end
 
  def create
    @item = Item.new(:owner => current_inventory_pool)

    check_fields_for_write_permissions

    unless @item.errors.any?
      saved = @item.update_attributes(params[:item])
    end

    respond_to do |format|
      format.json {
        if saved
          render(:status => :no_content, :nothing => true)
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
            redirect_to manage_copy_item_path(current_inventory_pool, @item.id), flash: {success: _("New item created.")}
          else
            redirect_to manage_inventory_path(current_inventory_pool), flash: {success: _("New item created.")}
          end
        else
          flash[:error] = @item.errors.full_messages.uniq
          redirect_to manage_new_item_path(current_inventory_pool)
        end
      }
    end
  end

  def update
    fetch_item_by_id

    if @item

      check_fields_for_write_permissions

      unless @item.errors.any?
        saved = @item.update_attributes(params[:item])
      end

    end

    respond_to do |format|
      format.json { 
        if saved
          render :status => :ok, json: @item.to_json(:methods => [:current_borrower, :current_return_date, :in_stock?],
                                                     :include => [:inventory_pool, :location, :model, :owner, :supplier])
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
            redirect_to manage_copy_item_path(current_inventory_pool, @item.id), flash: {success: _("Item saved.")}
          else
            redirect_to manage_inventory_path(current_inventory_pool), flash: {success: _("Item saved.")}
          end
        else
          @item = @item.reload
          flash[:error] = @item.errors.full_messages.uniq.join(", ")
          render :action => :edit
        end
      }
    end
  end

  def copy
    fetch_item_by_id
    @type = @item.type.downcase
    @item = @item.dup
    @item.owner = @current_inventory_pool
    @item.inventory_code = Item.proposed_inventory_code(current_inventory_pool)
    @item.serial_number = nil
    @item.name = nil
    render :new
  end
  
  def show
    fetch_item_by_id
  end

  def inspect
    fetch_item_by_id
    [:is_borrowable, :is_incomplete, :is_broken, :status_note].each do |attr|
      @item.update_attributes(attr => params[attr])
    end
    @item.save!
    render :status => :no_content, :nothing => true
  end

  private

  def fetch_item_by_id
    @item = Item.find params[:id]
  end

  def check_fields_for_write_permissions
    Field.all.each do |field|
      next unless field.permissions
      if field.get_value_from_params params[:item]
        unless field.editable current_user, current_inventory_pool, @item
          @item.errors.add(:base, _("You are not the owner of this item")+", "+_("therefore you may not be able to change some of these fields"))
        end
      end
    end
  end

end
