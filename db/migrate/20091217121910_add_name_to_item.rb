class AddNameToItem < ActiveRecord::Migration
  def self.up
   add_column :items, :name, :text
  end

  def self.down
    remove_column :items, :name
  end
end
