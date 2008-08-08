class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :inventory_code
      t.string :serial_number
      t.belongs_to :model
      t.belongs_to :location
      t.integer :status_const, :default => Item::BORROWABLE
      t.timestamps
    end
    
    add_index :items, :inventory_code, :unique => true
  end

  def self.down
    drop_table :items
  end
end
