class RefactorLocations < ActiveRecord::Migration
  def self.up
    change_table :items do |t|
      t.belongs_to :inventory_pool
      t.boolean :for_rental
      t.boolean :inventory_relevant
      t.string :responsible
    end

    Item.all.each do |item|
      item.update_attributes(:for_rental => item.is_borrowable, :inventory_pool_id => item.location.inventory_pool_id) if item.location
    end

    change_table :locations do |t|
      t.remove :inventory_pool_id
    end
  end

  def self.down
    change_table :locations do |t|
      t.belongs_to :inventory_pool
    end

    Item.all.each do |item|
      item.location.update_attributes(:inventory_pool_id => item.inventory_pool_id)
    end

    change_table :items do |t|
      t.remove :inventory_pool_id
      t.remove :for_rental
      t.remove :inventory_relevant
      t.remove :responsible
    end
  end
end
