connection = ActiveRecord::Base.connection

# is the database encoding correct?
character_set_key = 'character_set_database'
character_set_value = 'utf8'
query1 = connection.execute %Q(SHOW VARIABLES LIKE '#{character_set_key}';)

# is the database collation correct?
collation_key = 'collation_database'
collation_value = 'utf8_general_ci'
query2 = connection.execute %Q(SHOW VARIABLES LIKE '#{collation_key}';)

if query1.to_h[character_set_key] != character_set_value or query2.to_h[collation_key] != collation_value
  connection.update %Q(ALTER DATABASE #{connection.current_database} DEFAULT CHARACTER SET #{character_set_value} COLLATE #{collation_value};)

  if query1.to_h[character_set_key] != character_set_value
    puts "The MySQL setting for %s was wrong, it was set to %s, now it is set to %s" % [character_set_key, query1.to_h[character_set_key], character_set_value]
  end
  if query2.to_h[collation_key] != collation_value
    puts "The MySQL setting for %s was wrong, it was set to %s, now it is set to %s" % [collation_key, query2.to_h[collation_key], collation_value]
  end

  # are the encodings for the existing tables correct?
  only_tables_no_views = connection.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'").to_h.keys
  only_tables_no_views.each do |table_name|
    connection.execute %Q(ALTER TABLE #{table_name} DEFAULT CHARACTER SET #{character_set_value} COLLATE #{collation_value};)

    connection.columns(table_name).select{|column| not column.collation.nil? and column.collation != 'utf8_general_ci' }.each do |column|
      connection.execute %Q(ALTER TABLE #{table_name} MODIFY `#{column.name}` #{column.sql_type} CHARACTER SET #{character_set_value} COLLATE #{collation_value};)
    end
  end
end


