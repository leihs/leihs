class CreateBuildings < ActiveRecord::Migration
  def self.up
    create_table :buildings do |t|
      t.string :name
      t.string :code
    end
    
    change_table :locations do |t| 
      t.remove :building
      t.belongs_to :building
    end
  end

  def self.down
    drop_table :buildings
    
    change_table :locations do |t| 
      t.remove :building_id
      t.text :building
    end
    
  end
end
