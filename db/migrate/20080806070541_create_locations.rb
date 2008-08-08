class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.belongs_to :inventory_pool
      t.string  :name  # OPTIMIZE (shelf, etc...)

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
