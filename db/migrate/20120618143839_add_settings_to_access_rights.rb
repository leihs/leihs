class AddSettingsToAccessRights < ActiveRecord::Migration
  def change
    add_column :access_rights, :settings, :string, :limit => 1024
  end
end
