class AddSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :settings, :string, :limit => 1024
  end
end
