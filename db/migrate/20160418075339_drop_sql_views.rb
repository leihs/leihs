class DropSqlViews < ActiveRecord::Migration
  def up
    execute("DROP VIEW IF EXISTS partitions_with_generals")
    execute("DROP VIEW IF EXISTS visits")
  end
end
