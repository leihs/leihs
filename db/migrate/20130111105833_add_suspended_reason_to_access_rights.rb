class AddSuspendedReasonToAccessRights < ActiveRecord::Migration
  def change
    change_table :access_rights do |t|
      t.text :suspended_reason
    end
  end
end
