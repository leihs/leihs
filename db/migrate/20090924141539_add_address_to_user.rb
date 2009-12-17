class AddAddressToUser < ActiveRecord::Migration
  def self.up
   add_column :users, :address, :string
   add_column :users, :city, :string
   add_column :users, :zip, :string
   add_column :users, :country, :string
  end

  def self.down
    remove_column :users, :address
    remove_column :users, :city
    remove_column :users, :zip
    remove_column :users, :country
  end
end
