class AddCachedAvailability < ActiveRecord::Migration
  def self.up
    add_column :contract_lines, :cached_available, :boolean, :null => true, :default => nil
    add_column :order_lines, :cached_available, :boolean, :null => true, :default => nil
  end

  def self.down
    remove_column :contract_lines, :cached_available
    remove_column :order_lines, :cached_available
  end
end
