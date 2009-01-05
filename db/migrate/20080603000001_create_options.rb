class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.belongs_to :contract
      t.integer :quantity
      t.string :barcode
      t.string :name
      t.date :returned_date
      t.timestamps
    end
    foreign_key :options, :contract_id, :contracts
    
    create_table :option_maps do |t|
      t.belongs_to :inventory_pool
      t.string :barcode
      t.string :text
    end
    foreign_key :option_maps, :inventory_pool_id, :inventory_pools
  
  end
  
  def self.down
    drop_table :options
  end
end
