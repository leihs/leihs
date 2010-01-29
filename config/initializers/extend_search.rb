#sellittf#

# This is an extension of the Thinking-Sphinx plugin (http://github.com/freelancing-god/thinking-sphinx).
# It preloads the ids of the elements to search for,
# so then the scoping of the associations and named_scopes is relying on the model definition.
# No need to store foreign keys or additional attributes on the index definition.

# TODO remove this
class Array
      
  def search(*args)
    options = args.extract_options!
    options[:page] ||= 1
    options[:per_page] ||= 15
    
    unless empty?
      options[:with] ||= {}
      options[:with][:sphinx_internal_id] = collect(&:id)
      
      args << options
      first.class.search(*args) # TODO multiple classes search
    else
      paginate options
    end 
  end

end

####################################################################

#temp# 0501
module ActiveRecord

  class Base
    def self.find_for_ids(*args)
      sql = construct_finder_sql({:select => "DISTINCT #{table_name}.id"})
      result = connection.select_all(sanitize_sql(sql), "#{name} Load")
      ids = [] 
      result.each {|row| ids << row["id"].to_i }
      ids
    end
  end
      
  module NamedScope
    class Scope

      # merge
      def search(*args)
        options = args.extract_options!
        options[:page] ||= 1
        options[:per_page] ||= 15
        
        options[:with] ||= {}
        options[:with][:sphinx_internal_id] = find_for_ids 
        
        args << options
        class_name.constantize.search(*args)
      end

    end
  end
end

####################################################################

module ThinkingSphinx

#  # forces live update even in test environment
#  @@deltas_enabled = true
#  @@updates_enabled = true

  class Search
    def instances_from_class(klass, matches)
      index_options = klass.sphinx_index_options

      ids = matches.collect { |match| match[:attributes]["sphinx_internal_id"] }
      
      #sellittf#
      if klass == Item
        instances = ids.length > 0 ? klass.find(
          :all,
          :joins      => options[:joins],
          :conditions => {klass.primary_key_for_sphinx.to_sym => ids},
          :include    => (options[:include] || index_options[:include]),
          :select     => (options[:select]  || index_options[:select]),
          :retired    => options[:retired], #sellittf#
          :order      => (options[:sql_order] || index_options[:sql_order])
        ) : []
      else
       instances = ids.length > 0 ? klass.find(
          :all,
          :joins      => options[:joins],
          :conditions => {klass.primary_key_for_sphinx.to_sym => ids},
          :include    => (options[:include] || index_options[:include]),
          :select     => (options[:select]  || index_options[:select]),
          :order      => (options[:sql_order] || index_options[:sql_order])
        ) : []
      end

      # Raise an exception if we find records in Sphinx but not in the DB, so
      # the search method can retry without them. See 
      # ThinkingSphinx::Search.retry_search_on_stale_index.
      if options[:raise_on_stale] && instances.length < ids.length
        stale_ids = ids - instances.map { |i| i.id }
        raise StaleIdsException, stale_ids
      end

      # if the user has specified an SQL order, return the collection
      # without rearranging it into the Sphinx order
      return instances if (options[:sql_order] || index_options[:sql_order])

      ids.collect { |obj_id|
        instances.detect do |obj|
          obj.primary_key_for_sphinx == obj_id
        end
      }
    end
  end

  # TODO 0501
  # forces lower case index, providing case insensitive sorting
  class Attribute < ThinkingSphinx::Property
    def to_select_sql
      return nil unless include_as_association?
      
      separator = all_ints? || all_datetimes? || @crc ? ',' : ' '
      
      clause = @columns.collect { |column|
        part = column_with_prefix(column)
        case type
        when :string
          adapter.convert_nulls(part)
        when :datetime
          adapter.cast_to_datetime(part)
        when :multi
          part = adapter.cast_to_datetime(part)   if is_many_datetimes?
          part = adapter.convert_nulls(part, '0') if is_many_ints?
          part
        else
          part
        end
      }.join(', ')
      
      clause = adapter.crc(clause)                          if @crc
      clause = adapter.concatenate(clause, separator)       if concat_ws?
      clause = adapter.group_concatenate(clause, separator) if is_many?
      
      #sellittf start#
      #"#{clause} AS #{quote_column(unique_name)}"
      "LOWER(#{clause}) AS #{quote_column(unique_name)}"
      #sellittf end#
    end
  end

end
