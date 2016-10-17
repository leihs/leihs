class Manage::ItemsController < Manage::ApplicationController

  def index
    cip = unless params[:current_inventory_pool] == 'false'
             current_inventory_pool
          end
    @items = Item.filter params, cip
    set_pagination_header(@items) unless params[:paginate] == 'false'
  end

  def current_locations
    cip = unless params[:current_inventory_pool] == 'false'
             current_inventory_pool
          end
    items = Item.filter params, cip
    @locations = []
    items.each do |item|
      @locations.push \
        id: item.id,
        location: if current_inventory_pool.owner_or_responsible_for?(item)
                    item.current_location
                  else
                    item.inventory_pool.name
                  end
    end
  end

  def new
    @type = params[:type] ? params[:type] : 'item'
    @item = Item.new(owner: current_inventory_pool)
    @item.inventory_code = Item.proposed_inventory_code(current_inventory_pool)
    unless @current_user.has_role?(:lending_manager, current_inventory_pool)
      @item.inventory_pool = current_inventory_pool
    end
    @item.is_inventory_relevant = (super_user? ? true : false)
  end

  def edit
    fetch_item_by_id
  end

  def create
    @item = Item.new(owner: current_inventory_pool)

    check_fields_for_write_permissions

    unless @item.errors.any?
      saved = @item.update_attributes(params[:item])
    end

    respond_to do |format|
      format.json do
        if saved
          if params[:copy]
            render(status: :ok,
                   json: { id: @item.id,
                           redirect_url: \
                             manage_copy_item_path(current_inventory_pool,
                                                   @item.id) })
          else
            render(status: :ok,
                   json: @item.to_json(include: [:inventory_pool,
                                                 :location,
                                                 :model,
                                                 :owner,
                                                 :supplier]))
          end
        else
          if @item
            render text: @item.errors.full_messages.uniq.join(', '),
                   status: :bad_request
          else
            render json: {}, status: :not_found
          end
        end
      end
    end
  end

  def update
    fetch_item_by_id

    if @item

      check_fields_for_write_permissions

      unless @item.errors.any?
        # NOTE avoid to lose already stored properties
        if params[:item][:properties]
          params[:item][:properties] = \
            @item.properties.merge params[:item][:properties]
        end
        saved = @item.update_attributes(params[:item])
      end

    end

    respond_to do |format|
      format.json do
        if saved
          if params[:copy]
            render(status: :ok,
                   json: { redirect_url: \
                             manage_copy_item_path(current_inventory_pool,
                                                   @item.id) })
          else
            render(status: :ok,
                   json: @item.to_json(include: [:inventory_pool,
                                                 :location,
                                                 :model,
                                                 :owner,
                                                 :supplier]))
          end
        else
          if @item
            render text: @item.errors.full_messages.uniq.join(', '),
                   status: :bad_request
          else
            render json: {}, status: :not_found
          end
        end
      end
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
    head status: :ok
  end

  def upload
    @item = fetch_item_by_id
    params[:files].each do |file|
      if params[:type] == 'attachment'
        attachment = Attachment.new(file: file,
                                    filename: file.original_filename,
                                    item_id: @item.id)
        attachment.save
      else
        raise 'Unknown attachment type'
      end
    end
    head status: :ok
  end

  private

  def fetch_item_by_id
    @item = Item.find params[:id]
  end

  def check_fields_for_write_permissions
    Field.all.each do |field|
      next unless field.data['permissions']
      next unless field.get_value_from_params params[:item]
      next if field.editable(current_user, current_inventory_pool, @item)
      @item
        .errors
        .add(:base,
             _('You are not the owner of this item') \
             + ', ' \
             + _('therefore you may not be able to change some of these fields'))
    end
  end

end
