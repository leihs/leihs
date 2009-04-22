#sellittf#

module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      
      def dump_database
#        skip_tables = ["schema_info"]
#        target_tables = (tables - skip_tables)
        
#old#        
#        tables.each do |t|
#          execute("SHOW INDEX FROM #{t}").all_hashes.each do |h|
#            execute("ALTER TABLE #{t} DROP FOREIGN KEY #{h["Key_name"]}") if h["Key_name"].include? "fk_"
#          end
#        end
        r = ""
#old#   r += structure_dump
        r += tables.map {|t| dump(t) }.join("\n\n")
        r.split("\n\n")
      end
            
      def dump(table)
        all_hashes = execute("SELECT * FROM #{table}").all_hashes
        all_hashes.map { |h| "INSERT INTO #{table} (#{h.keys.join(',')}) VALUES (#{h.values.map{|v| (v.nil? ? "NULL" : "'#{v}'") }.join(',')});" }.join("\n\n")
      end

      def restore_database(sql_dump)
#old#
#        db = current_database
#        recreate_database db
#        execute("USE #{db}")
        tables.each {|t| execute("TRUNCATE #{t}") }
        sql_dump = Array(sql_dump)
        sql_dump.each {|s| execute(s) unless s.blank? }
      end
      
    end
  end
end