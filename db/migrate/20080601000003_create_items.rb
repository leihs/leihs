class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :inventory_code
      t.string :serial_number
      t.belongs_to :model
      t.belongs_to :location
      t.belongs_to :supplier
      t.integer :owner_id
      t.integer :parent_id, :null => true # for package purpose
      t.integer :required_level, :default => AccessRight::CUSTOMER
      t.string :invoice_number
      t.date :invoice_date
      t.date :last_check, :default => nil
      t.date :retired, :default => nil
      t.string :retired_reason, :default => nil
      t.decimal :price, :precision => 8, :scale => 2
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
    foreign_key :items, :owner_id, :inventory_pools
    foreign_key :items, :parent_id, :items
  end

  def self.down
    drop_table :items
  end
end
