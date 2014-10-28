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
      format.html {
        session[:params] = nil if params[:filters] == "reset"
        items = Item.filter params.clone.merge({paginate: "false", all: "true"}), current_inventory_pool
        @responsibles = InventoryPool.uniq.joins(:items).where("items.id IN (#{items.select("items.id").to_sql})").where(InventoryPool.arel_table[:id].eq(Item.arel_table[:inventory_pool_id]))
      }
      format.json {
        session[:params] = params.symbolize_keys
        @inventory = current_inventory_pool.inventory params
        set_pagination_header(@inventory) unless params[:paginate] == "false"
      }
    end
  end

  def show
    @record = current_inventory_pool.items.find_by_inventory_code(params[:inventory_code]) ||
              current_inventory_pool.options.find_by_inventory_code(params[:inventory_code])
  end

  def helper
    @fields = Field.all.select {|f| f.accessible_by? current_user, current_inventory_pool }
  end

  def csv_export
    send_data InventoryPool.csv_export(current_inventory_pool, params),
              type: 'text/csv; charset=utf-8; header=present',
              disposition: "attachment; filename=#{_("Items-leihs")}.csv"
  end
end
