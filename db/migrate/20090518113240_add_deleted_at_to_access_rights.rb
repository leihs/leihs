class AddDeletedAtToAccessRights < ActiveRecord::Migration
  def self.up
    add_column :access_rights, :deleted_at, :date
  end

  def self.down
    remove_column :access_rights, :deleted_at
  end

end
