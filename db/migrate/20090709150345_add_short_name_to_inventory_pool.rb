class AddShortNameToInventoryPool < ActiveRecord::Migration
  def self.up
    add_column :inventory_pools, :shortname, :string
  end

  def self.down
    remove_column :inventory_pools, :shortname
  end
end
