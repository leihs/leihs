class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :inventory_code
      t.belongs_to :model
      t.belongs_to :inventory_pool
      t.integer :status, :default => Item::AVAILABLE
      t.timestamps
    end
    
    add_index :items, :inventory_code, :unique => true
  end

  def self.down
    drop_table :items
  end
end
