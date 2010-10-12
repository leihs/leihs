class AddPrintContractsToInventoryPool < ActiveRecord::Migration
  def self.up
    add_column :inventory_pools, :print_contracts, :boolean, :default => true
  end

  def self.down
    remove_column :inventory_pools, :print_contracts
  end
end
