class Manage::InventoryController < Manage::ApplicationController

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
    require 'csv'

    items = current_inventory_pool ? Item.filter(params.clone.merge({paginate: "false", all: "true"}), current_inventory_pool) : Item.unscoped

    options = if current_inventory_pool
                if params[:type] != "license" and [:unborrowable, :retired, :category_id, :in_stock, :incomplete, :broken, :owned, :responsible_id, :unused_models].all? {|param| params[param].blank?}
                  Option.filter params.clone.merge({paginate: "false", sort: "product", order: "ASC"}), current_inventory_pool
                else
                  []
                end
              else
                Option.unscoped
              end

    global = current_inventory_pool ? false : true
    include_params = [:location, :inventory_pool, :owner, :supplier]
    include_params += global ? [:model] : [:item_lines, model: [:model_links, :model_groups]]

    objects = []
    items.includes(include_params).find_each do |i, index|
      objects << i.to_csv_array(global: global) unless i.nil? # How could an item ever be nil?
    end
    unless options.blank?
      options.includes(:inventory_pool).find_each do |o|
        objects << o.to_csv_array unless o.nil? # How could an item ever be nil?
      end
    end

    csv_header = objects.flat_map(&:keys).uniq

    csv_string = CSV.generate({ :col_sep => ";", :quote_char => "\"", :force_quotes => true }) do |csv|
      csv << csv_header
      objects.each do |object|
        csv << csv_header.map {|h| object[h] }
      end
    end

    send_data csv_string, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=#{_("Items-leihs")}.csv"
  end
end
