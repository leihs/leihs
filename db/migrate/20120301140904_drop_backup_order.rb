class DropBackupOrder < ActiveRecord::Migration

  def up
    drop_table :backup_order_lines
    drop_table :backup_orders
  end

  def down
  end
end
