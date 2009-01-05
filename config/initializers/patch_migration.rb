# http://seb.box.re/2006/7/29/foreign-key-and-rails-migration

module MigrationHelpers
  def foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}" 

    execute %{alter table #{from_table} add constraint #{constraint_name} foreign key (#{from_column}) references #{to_table}(id)}
  end
end

class ActiveRecord::Migration
  extend MigrationHelpers
end