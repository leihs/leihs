class ItemInventoryRelevanceDefault < ActiveRecord::Migration
  def self.up
    # per Ramon the default should be "not inventory relevant" by default
    change_column :items, :is_inventory_relevant, :boolean, :default => false
  end

  def self.down
    change_column :items, :is_inventory_relevant, :boolean, :default => true
  end
end
