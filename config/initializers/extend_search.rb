#sellittf#

# This is an extension of the Thinking-Sphinx plugin (http://github.com/freelancing-god/thinking-sphinx).
# It preloads the ids of the elements to search for,
# so then the scoping of the associations and named_scopes is relying on the model definition.
# No need to store foreign keys or additional attributes on the index definition.

class Array
      
  def search(q, options = {})
    options[:page] ||= 1
    options[:per_page] ||= 15
    unless self.empty?
      # TODO multiple classes search ?
      # TODO merge conditions
      options[:conditions] = {:id => self.collect(&:id)}
      first.class.search(q, options)
    else
      paginate options
    end 
  end

end

module ActiveRecord

  class Base
    def self.find_for_ids(*args)
      sql = construct_finder_sql({:select => "DISTINCT #{table_name}.id"})
      result = connection.select_all(sanitize_sql(sql), "#{name} Load")
      ids = [] 
      result.each {|row| ids << row["id"].to_i }
      ids
    end

    def touch
      self.update_attribute :updated_at, Time.now
    end
  end
      
  module NamedScope
    class Scope

      # merge
      def search(*args)
        options = args.extract_options!
        options[:page] ||= 1
        options[:per_page] ||= 15
          # TODO merge conditions
          options[:conditions] = {:id => find_for_ids}
          class_name.constantize.search(args, options)
      end

    end
  end
end


module ThinkingSphinx

  # forces live update even in test environment
  @@deltas_enabled = true
  @@updates_enabled = true

  module ActiveRecord
    module HasManyAssociation
      
      # merge
      def search(*args)
        options = args.extract_options!
        options[:page] ||= 1
        options[:per_page] ||= 15
          # TODO merge conditions
          options[:conditions] = {:id => find_for_ids}
          class_name.constantize.search(args, options)
      end

    end
  end

  # forces lower case index, providing case insensitive sorting
  class Attribute
    def to_select_sql
      return nil unless include_as_association?
      
      clause = @columns.collect { |column|
        "LOWER(#{column_with_prefix(column)})"
      }.join(', ')
      
      separator = all_ints? ? ',' : ' '
      
      clause = adapter.concatenate(clause, separator)       if concat_ws?
      clause = adapter.group_concatenate(clause, separator) if is_many?
      clause = adapter.cast_to_datetime(clause)             if type == :datetime
      clause = adapter.convert_nulls(clause)                if type == :string
      
      "#{clause} AS #{quote_column(unique_name)}"
    end    
  end

end

