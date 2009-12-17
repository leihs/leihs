class AddSuspendedAtToAccessRights < ActiveRecord::Migration
  def self.up
    add_column :access_rights, :suspended_at, :date
  end

  def self.down
    remove_column :access_rights, :suspended_at
  end
end
