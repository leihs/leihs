class AddAutomaticSuspensionToInventoryPools < ActiveRecord::Migration
  def change
    add_column :inventory_pools, :automatic_suspension, :boolean, null: false, default: false
    add_column :inventory_pools, :automatic_suspension_reason, :text
  end
end
