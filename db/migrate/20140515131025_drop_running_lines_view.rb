class DropRunningLinesView < ActiveRecord::Migration
  def change

    execute("DROP VIEW IF EXISTS running_lines")

  end
end
