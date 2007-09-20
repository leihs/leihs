class AddColumnGestell < ActiveRecord::Migration
  def self.up
    add_column :pakets, :gestell, :string 
  end

  def self.down
    remove_column :pakets, :gestell
  end
end
