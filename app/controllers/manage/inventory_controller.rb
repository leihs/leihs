class Manage::InventoryController < Manage::ApplicationController

  private

  # NOTE overriding super controller
  def required_manager_role
    open_actions = [:index]
    if open_actions.include?(action_name.to_sym)
      require_role :group_manager, current_inventory_pool
    else
      super
    end
  end

  public

  def index
    respond_to do |format|
      format.html do
        session[:params] = nil if params[:filters] == 'reset'
        items = Item.filter(params.clone.merge(paginate: 'false', all: 'true'),
                            current_inventory_pool)
        @responsibles = \
          InventoryPool
            .uniq
            .joins(:items)
            .where("items.id IN (#{items.select('items.id').to_sql})")
            .where(
              InventoryPool
                .arel_table[:id]
                .eq(Item.arel_table[:inventory_pool_id])
            )
      end
      format.json do
        session[:params] = params.symbolize_keys
        @inventory = current_inventory_pool.inventory params
        set_pagination_header(@inventory) unless params[:paginate] == 'false'
      end
    end
  end

  def show
    @record = \
      current_inventory_pool
        .items
        .find_by_inventory_code(params[:inventory_code]) || \
      current_inventory_pool
        .options
        .find_by_inventory_code(params[:inventory_code])

    @record ||= \
      begin
        owned_item = \
          current_inventory_pool
          .own_items
          .find_by_inventory_code(params[:inventory_code])
        if owned_item
          { error: _('You do not have the responsibility to lend this item. ' \
                     "Responsible for this item is the pool \"%s\".") % \
                    owned_item.inventory_pool.name }
        end
      end
  end

  def helper
    @fields = Field.all.select do |f|
      f.accessible_by? current_user, current_inventory_pool
    end
  end

  def csv_export
    send_data \
      InventoryPool.csv_export(current_inventory_pool, params),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: \
        'attachment; ' \
        "filename=#{current_inventory_pool.shortname}-#{_('Inventory')}.csv"
  end

  def excel_export
    send_data \
      InventoryPool.excel_export(current_inventory_pool, params),
      type: 'application/xlsx',
      disposition: \
        "filename=#{current_inventory_pool.shortname}-#{_('Inventory')}.xlsx"
  end

  def csv_import
    if request.post?
      items = current_inventory_pool.csv_import(current_inventory_pool,
                                                params[:csv_file].tempfile)

      # &:valid?
      @valid_items, @invalid_items = items.partition { |item| item.errors.empty? }
    end
  end

end
