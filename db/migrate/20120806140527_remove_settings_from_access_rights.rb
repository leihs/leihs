class RemoveSettingsFromAccessRights < ActiveRecord::Migration
  def change
    remove_column :access_rights, :settings
  end
end
