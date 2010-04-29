module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter
      
      def data_dump
        if supports_views?
          sql = "SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'"
        else
          sql = "SHOW TABLES"
        end

        select_all(sql).inject("") do |data, table|
          table.delete('Table_type')
          quoted_table_name = quote_table_name(table.to_a.first.last)
          records = select_all("SELECT * FROM #{quoted_table_name}")
          data += records.collect do |record|
            sanitized_assignments = record.map do |attr, value|
              "#{quote_column_name(attr)} = #{quote_bound_value(value)}"
            end.join(', ')
            "INSERT INTO #{quoted_table_name} SET #{sanitized_assignments};"
          end.join("\n")
        end
      end

      # TODO dry with ActiveRecord::Base.quote_bound_value
      def quote_bound_value(value) #:nodoc:
        if value.respond_to?(:map) && !value.acts_like?(:string)
          if value.respond_to?(:empty?) && value.empty?
            quote(nil)
          else
            value.map { |v| quote(v) }.join(',')
          end
        else
          quote(value)
        end
      end
   
    end
  end
end