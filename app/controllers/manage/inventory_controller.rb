class Manage::InventoryController < Manage::ApplicationController

  def show
    @record = current_inventory_pool.items.find_by_inventory_code(params[:inventory_code]) ||
              current_inventory_pool.options.find_by_inventory_code(params[:inventory_code])
  end

  def helper
    @fields = Field.accessible_by current_user, current_inventory_pool
  end

  def index
    @inventory = Inventory.filter params, current_inventory_pool
    set_pagination_header(@inventory) unless params[:paginate] == "false"
  end

  def responsibles
    items = Item.filter params.clone.merge({paginate: "false", all: "true"}), current_inventory_pool
    @responsibles = InventoryPool.uniq.joins(:items).where("items.id IN (#{items.select("items.id").to_sql})").where(InventoryPool.arel_table[:id].eq(Item.arel_table[:inventory_pool_id]))
  end

  def csv_export
    require 'csv'
    items = Item.filter params.clone.merge({paginate: "false", all: "true"}), current_inventory_pool
    options = if [:unborrowable, :retired, :category_id, :in_stock, :incomplete, :broken, :owned, :responsible_id, :unused_models].all? {|param| params[param].blank?}
      Option.filter params.clone.merge({paginate: "false", sort: "name", order: "ASC"}), current_inventory_pool
    else
      []
    end
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
  end
  
end