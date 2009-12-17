class AddNeedsPermissionToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :needs_permission, :boolean
  end

  def self.down
    remove_column :items, :needs_permission
  end
end
