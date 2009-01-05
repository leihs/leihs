class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :inventory_code #, :null => false
      t.string :serial_number
      t.belongs_to :model #, :null => false
      t.belongs_to :location #, :null => false
      t.integer :parent_id, :null => true # for package purpose
      t.integer :required_level, :default => AccessRight::EVERYBODY
      t.boolean :is_broken, :default => false
      t.boolean :is_incomplete, :default => false
      t.boolean :is_borrowable, :default => true
      t.timestamps
    end
    
    add_index :items, :inventory_code, :unique => true
    add_index :items, :required_level
    add_index :items, :is_broken
    add_index :items, :is_incomplete
    add_index :items, :is_borrowable

    foreign_key :items, :model_id, :models
    foreign_key :items, :location_id, :locations
    foreign_key :items, :parent_id, :items
  end

  def self.down
    drop_table :items
  end
end
