class ValidatingItemsMore < ActiveRecord::Migration

  def self.up    

    Item.update_all({:is_inventory_relevant => false}, {:is_inventory_relevant => nil})
    Item.update_all({:needs_permission => false}, {:needs_permission => nil})

  end
  
  def self.down
  end
end
