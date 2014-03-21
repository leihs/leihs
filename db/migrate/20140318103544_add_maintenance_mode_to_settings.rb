class AddMaintenanceModeToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :disable_manage_section, :boolean, null: false, default: false
    add_column :settings, :disable_manage_section_message, :text
    add_column :settings, :disable_borrow_section, :boolean, null: false, default: false
    add_column :settings, :disable_borrow_section_message, :text
  end
end
