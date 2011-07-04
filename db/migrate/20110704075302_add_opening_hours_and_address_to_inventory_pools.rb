class AddOpeningHoursAndAddressToInventoryPools < ActiveRecord::Migration
  def change
    
    add_column :inventory_pools, :opening_hours, :text
    add_column :inventory_pools, :address, :text    
    
  end
end
