class AddAccessLevelToAccessRights < ActiveRecord::Migration
  def self.up
   add_column :access_rights, :access_level, :integer
  end

  def self.down
    remove_column :access_rights, :access_level
  end
end
