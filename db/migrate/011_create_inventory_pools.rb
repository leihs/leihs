class CreateInventoryPools < ActiveRecord::Migration
  def self.up
    create_table :inventory_pools do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :inventory_pools
  end
end
