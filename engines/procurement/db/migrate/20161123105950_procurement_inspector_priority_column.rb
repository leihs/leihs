class ProcurementInspectorPriorityColumn < ActiveRecord::Migration
  def up
    add_column(:procurement_requests,
               :inspector_priority,
               "ENUM('low', 'medium', 'high', 'mandatory')")

    execute <<-SQL
      UPDATE procurement_requests
      SET inspector_priority = 'medium';
    SQL

    change_column(:procurement_requests,
                  :inspector_priority,
                  "ENUM('low', 'medium', 'high', 'mandatory')",
                  null: false,
                  default: 'medium')
  end

  def down
    remove_column :procurement_requests, :inspector_priority
  end
end
