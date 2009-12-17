class ValidatingItems < ActiveRecord::Migration

  def self.up    

    Item.update_all({:is_borrowable_allowed => true}, {:is_borrowable => true, :is_borrowable_allowed => nil})
    Item.update_all({:is_borrowable_allowed => false}, {:is_borrowable_allowed => nil})
    Item.update_all({:is_borrowable => false}, {:is_borrowable_allowed => false, :is_borrowable => true})

  end
  
  def self.down
  end
end
