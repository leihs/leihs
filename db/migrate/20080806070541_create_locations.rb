class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.belongs_to :inventory_pool
      t.boolean :is_main, :default => false
      t.string  :building
      t.string  :room
      t.string  :shelf

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
