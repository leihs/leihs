class ImproveSuspendedUsers < ActiveRecord::Migration
  def self.up
    rename_column :access_rights, :suspended_at, :suspended_until
    AccessRight.update_all("suspended_until = DATE_ADD(suspended_until, INTERVAL 1000 YEAR)", "suspended_until IS NOT NULL")
  end

  def self.down
    AccessRight.update_all("suspended_until = DATE_SUB(suspended_until, INTERVAL 1000 YEAR)", "suspended_until IS NOT NULL")
    rename_column :access_rights, :suspended_until, :suspended_at
  end
end
