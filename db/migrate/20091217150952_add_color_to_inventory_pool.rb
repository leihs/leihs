class AddColorToInventoryPool < ActiveRecord::Migration
  def self.up
   add_column :inventory_pools, :color, :text
  end

  def self.down
    remove_column :inventory_pools, :color
  end
end
