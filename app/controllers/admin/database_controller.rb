#### Quickly list missing foreign key indexes
#### source: https://tomafro.net/2009/09/quickly-list-missing-foreign-key-indexes
#
#c = ActiveRecord::Base.connection
#c.tables.collect do |t|
#  columns = c.columns(t).collect(&:name).select {|x| x.ends_with?("_id" || x.ends_with("_type"))}
#  indexed_columns = c.indexes(t).collect(&:columns).flatten.uniq
#  unindexed = columns - indexed_columns
#  unless unindexed.empty?
#    puts "#{t}: #{unindexed.join(", ")}"
#  end
#end

class Admin::DatabaseController < Admin::ApplicationController

  def indexes
    connection = ActiveRecord::Base.connection

    @indexes_found, @indexes_not_found = begin
      [
        ["access_rights", ["deleted_at"]],
        ["access_rights", ["inventory_pool_id"]],
        ["access_rights", ["role_id"]],
        ["access_rights", ["suspended_until"]],
        ["access_rights", ["user_id", "inventory_pool_id", "deleted_at"]],
        ["accessories", ["model_id"]],
        ["accessories_inventory_pools", ["accessory_id", "inventory_pool_id"], :unique => true],
        ["accessories_inventory_pools", ["inventory_pool_id"]],
        ["addresses", ["street", "zip_code", "city", "country_code"], :unique => true],
        ["attachments", ["model_id"]],
        ["audits", ["associated_id", "associated_type"]],
        ["audits", ["auditable_id", "auditable_type"]],
        ["audits", ["created_at"]],
        ["audits", ["thread_id"]],
        ["audits", ["user_id", "user_type"]],
        ["contract_lines", ["contract_id"]],
        ["contract_lines", ["end_date"]],
        ["contract_lines", ["item_id"]],
        ["contract_lines", ["model_id"]],
        ["contract_lines", ["option_id"]],
        ["contract_lines", ["returned_date", "contract_id"]],
        ["contract_lines", ["start_date"]],
        ["contract_lines", ["type", "contract_id"]],
        ["contracts", ["inventory_pool_id"]],
        ["contracts", ["status"]],
        ["contracts", ["user_id"]],
        ["groups", ["inventory_pool_id"]],
        ["groups_users", ["group_id"]],
        ["groups_users", ["user_id", "group_id"], :unique => true],
        ["histories", ["target_type", "target_id"]],
        ["histories", ["type_const"]],
        ["histories", ["user_id"]],
        ["holidays", ["inventory_pool_id"]],
        ["holidays", ["start_date", "end_date"]],
        ["images", ["model_id"]],
        ["inventory_pools", ["name"], :unique => true],
        ["inventory_pools_model_groups", ["inventory_pool_id"]],
        ["inventory_pools_model_groups", ["model_group_id"]],
        ["items", ["inventory_code"], :unique => true],
        ["items", ["inventory_pool_id"]],
        ["items", ["is_borrowable"]],
        ["items", ["is_broken"]],
        ["items", ["is_incomplete"]],
        ["items", ["location_id"]],
        ["items", ["model_id", "retired", "inventory_pool_id"]],
        ["items", ["owner_id"]],
        ["items", ["parent_id", "retired"]],
        ["items", ["retired"]],
        ["languages", ["active", "default"]],
        ["languages", ["name"], :unique => true],
        ["locations", ["building_id"]],
        ["model_group_links", ["ancestor_id"]],
        ["model_group_links", ["descendant_id", "ancestor_id", "direct"]],
        ["model_group_links", ["direct"]],
        ["model_groups", ["type"]],
        ["model_groups_parents_backup", ["model_group_id"]],
        ["model_groups_parents_backup", ["parent_id"]],
        ["model_links", ["model_group_id", "model_id"]],
        ["model_links", ["model_id", "model_group_id"]],
        ["models", ["is_package"]],
        ["models_compatibles", ["compatible_id"]],
        ["models_compatibles", ["model_id"]],
        ["notifications", ["user_id"]],
        ["options", ["inventory_pool_id"]],
        ["partitions", ["model_id", "inventory_pool_id", "group_id"], :unique => true],
        ["properties", ["model_id"]],
        ["roles", ["lft"]],
        ["roles", ["name"]],
        ["roles", ["parent_id"]],
        ["roles", ["rgt"]],
        ["users", ["authentication_system_id"]],
        ["workdays", ["inventory_pool_id"]]
      ].partition do |table, columns, options|
          indexes = connection.indexes(table)
          index = indexes.detect {|x| x.columns == columns}
          if not index
            false
          elsif options.blank?
            true
          else
            index.unique == !!options[:unique]
          end
        end
      end
  end

  def consistency
    flash[:error] = _("This report is not complete yet! Additional checks are coming soon...")
    @missing_references = {
        "items with missing model" => Item.unscoped.joins("LEFT JOIN models AS x ON items.model_id = x.id").where(x: {id: nil}),
        "items with missing parent item" => Item.unscoped.joins("LEFT JOIN items AS x ON items.parent_id = x.id").where(x: {id: nil}).where("items.parent_id IS NOT NULL"),
        "items with missing owner inventory_pool" => Item.unscoped.joins("LEFT JOIN inventory_pools AS x ON items.owner_id = x.id").where(x: {id: nil}),
        "items with missing responsible inventory_pool" => Item.unscoped.joins("LEFT JOIN inventory_pools AS x ON items.inventory_pool_id = x.id").where(x: {id: nil}).where("items.inventory_pool_id IS NOT NULL"),

        "contracts with missing inventory_pool" => Contract.unscoped.joins("LEFT JOIN inventory_pools AS x ON contracts.inventory_pool_id = x.id").where(x: {id: nil}),
        "contracts with missing user" => Contract.unscoped.joins("LEFT JOIN users AS x ON contracts.user_id = x.id").where(x: {id: nil}),

        "item_lines with missing item" => ItemLine.unscoped.joins("LEFT JOIN items AS x ON contract_lines.item_id = x.id").where(x: {id: nil}).where("contract_lines.item_id IS NOT NULL"),
        "option_lines with missing option" => OptionLine.unscoped.joins("LEFT JOIN options AS x ON contract_lines.option_id = x.id").where(x: {id: nil})
    }
  end

end




