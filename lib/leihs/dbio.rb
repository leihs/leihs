module Leihs
  module DBIO
    class << self

      TABLES = ActiveRecord::Base.connection.tables

      def reload!
        load File.absolute_path(__FILE__)
      end

      def rows(table)
        class_name = "LeihsDBIO#{table.to_s.capitalize}"
        eval <<-RB.strip_heredoc
          class ::#{class_name} < ActiveRecord::Base
            self.table_name = '#{table}'
          end
        RB
        class_name.constantize.all.map(&:attributes)
      end

      def data
        TABLES.map do |table|
          [table, (rows table)]
        end.to_h
      end

      def export(filename = nil)
        filename ||= Rails.root.join('tmp', 'db_data.yml')
        ::IO.write filename, data.to_yaml
      end
    end

  end
end
