class AddNotesToItem < ActiveRecord::Migration
  def self.up
   add_column :items, :note, :text
  end

  def self.down
    remove_column :items, :note
  end
end
