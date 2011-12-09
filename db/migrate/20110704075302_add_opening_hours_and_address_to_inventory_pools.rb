class AddOpeningHoursAndAddressToInventoryPools < ActiveRecord::Migration
  def self.up
    
    add_column :inventory_pools, :opening_hours, :text
    add_column :inventory_pools, :address, :text    
    
  end
  
  def self.down
  end
end
