# From: http://seb.box.re/2006/7/29/foreign-key-and-rails-migration
# See also: http://soniahamilton.wordpress.com/2008/10/01/ruby-on-rails-foreign-key-constraints-in-mysql/

module MigrationHelpers
  def foreign_key(from_table, from_column, to_table, constraint_name = nil)
    constraint_name ||= "fk_#{from_table}_#{from_column}" 
    execute %{alter table #{from_table} add constraint #{constraint_name} foreign key (#{from_column}) references #{to_table}(id)}
  end

  #sellittf#
  def remove_foreign_key(from_table, from_column, constraint_name = nil)
    constraint_name ||= "fk_#{from_table}_#{from_column}" 
    execute %{alter table #{from_table} drop foreign key #{constraint_name}}
  end

  #sellittf#
  def remove_foreign_key_and_add_index(table, column, constraint_name = nil)
    remove_foreign_key table, column, constraint_name
    add_index table, column
  end

  #sellittf#
  def remove_index_and_add_foreign_key(table, column, foreign_table, constraint_name = nil)
    remove_index table, column
    foreign_key table, column, foreign_table, constraint_name
  end
end

class ActiveRecord::Migration
  extend MigrationHelpers
end
