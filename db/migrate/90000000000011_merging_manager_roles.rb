class MergingManagerRoles < ActiveRecord::Migration

  def self.up    
    inventory_manager = Role.find_by_name('inventory manager')
    lending_manager = Role.find_by_name('lending manager')
    customer = Role.find_by_name('customer')

    AccessRight.update_all({:role_id => inventory_manager}, {:role_id => lending_manager})

    customer.move_to_child_of(inventory_manager)
    lending_manager.destroy
    
    inventory_manager.update_attributes(:name => 'manager')
  end
  
  def self.down
  end
end
