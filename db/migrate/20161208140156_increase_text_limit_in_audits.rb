class IncreaseTextLimitInAudits < ActiveRecord::Migration
  def change
    change_column :audits, :audited_changes, :text, limit: 16777215
  end
end
