class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :street
      t.string :zip_code
      t.string :city
      t.string :country_code
      t.float :latitude
      t.float :longitude 
    end
    change_table :addresses do |t|
      t.index [:street, :zip_code, :city, :country_code], :unique => true
    end

    change_table :inventory_pools do |t|
      t.remove :address
      t.belongs_to :address
    end
  end
  
  def self.down
  end
end
