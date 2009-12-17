class AddEmailToInventoryPool < ActiveRecord::Migration
  def self.up
    add_column :inventory_pools, :email, :string
  end

  def self.down
    remove_column :inventory_pools, :email
  end
end
