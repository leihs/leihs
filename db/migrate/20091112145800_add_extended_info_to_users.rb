class AddExtendedInfoToUsers < ActiveRecord::Migration
  def self.up
   add_column :users, :extended_info, :text # serialized
  end

  def self.down
    remove_column :users, :extended_info
  end

end
