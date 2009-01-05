class CreateAccessories < ActiveRecord::Migration
  def self.up
    create_table :accessories do |t|
      t.belongs_to :model
      t.string :name
      # TODO need quantity?
    end
    foreign_key :accessories, :model_id, :models


    create_table :accessories_inventory_pools, :id => false do |t|
      t.belongs_to :accessory
      t.belongs_to :inventory_pool
    end
    add_index(:accessories_inventory_pools, [:accessory_id, :inventory_pool_id], :unique => true, :name => 'index_accessories_inventory_pools')
    foreign_key :accessories_inventory_pools, :accessory_id, :accessories
    foreign_key :accessories_inventory_pools, :inventory_pool_id, :inventory_pools
    
  end

  def self.down
    drop_table :accessories
    drop_table :accessories_inventory_pools
  end
end
