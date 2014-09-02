class NilifyEmptyStrings < ActiveRecord::Migration
  def change

    only_tables_no_views = execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'").to_h.keys
    only_tables_no_views.each do |table_name|
      columns(table_name).select{|c| c.type == :string and c.null }.each do |column|
        execute %Q(UPDATE `#{table_name}` SET `#{column.name}` = NULL WHERE `#{column.name}` REGEXP '^\ *$')
      end
    end

  end
end
