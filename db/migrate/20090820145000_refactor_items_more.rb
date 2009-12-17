class RefactorItemsMore < ActiveRecord::Migration
  def self.up
    rename_column(:items, :inventory_relevant, :is_inventory_relevant)
    change_column_default(:items, :is_inventory_relevant, true)
    change_column_default(:items, :needs_permission, false)
  end

  def self.down
    change_column_default(:items, :needs_permission, nil)
    change_column_default(:items, :is_inventory_relevant, nil)
    rename_column(:items, :is_inventory_relevant, :inventory_relevant)
  end
end
