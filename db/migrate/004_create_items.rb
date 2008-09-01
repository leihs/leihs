class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :inventory_code #, :null => false
      t.string :serial_number
      t.belongs_to :model #, :null => false
      t.belongs_to :location #, :null => false
      t.integer :status_const, :default => Item::BORROWABLE
      t.timestamps
    end
    
    add_index :items, :inventory_code, :unique => true
  end

  def self.down
    drop_table :items
  end
end
