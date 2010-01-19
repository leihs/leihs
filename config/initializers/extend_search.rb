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
        options[:with][:sphinx_internal_id] = find_for_ids #old# collect(&:id) 
        
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

  module ActiveRecord

    module HasManyAssociation

#old#
#      # merge
#      def search(*args)
#        options = args.extract_options!
#        options[:page] ||= 1
#        options[:per_page] ||= 15
#          # TODO merge conditions
#          options[:conditions] = {:id => find_for_ids}
#          class_name.constantize.search(args, options)
#      end

      # TODO 0501 remove this patch after gem update > 1.3.14
      def search(*args)
        foreign_key = @reflection.primary_key_name
        stack = [@reflection.options[:through]].compact
        
        #patch start#
        @reflection.klass.define_indexes
        #patch end#
        
        attribute   = nil
        (@reflection.klass.sphinx_indexes || []).each do |index|
          attribute = index.attributes.detect { |attrib|
            attrib.columns.length == 1 &&
            attrib.columns.first.__name  == foreign_key.to_sym
          }
          break if attribute
        end
        
        raise "Missing Attribute for Foreign Key #{foreign_key}" unless attribute
        
        options = args.extract_options!
        options[:with] ||= {}
        options[:with][attribute.unique_name] = @owner.id
        
        args << options
        @reflection.klass.search(*args)
      end
    end
  
  end

#old#
#  class Search
#    def populate
#      return if @populated
#      @populated = true
#      
#      retry_on_stale_index do
#        begin
#          log "Querying: '#{query}'"
#          runtime = Benchmark.realtime {
#            @results = client.query query, indexes, comment
#          }
#          log "Found #{@results[:total_found]} results", :debug,
#            "Sphinx (#{sprintf("%f", runtime)}s)"
#        rescue Errno::ECONNREFUSED => err
#          raise ThinkingSphinx::ConnectionError,
#            'Connection to Sphinx Daemon (searchd) failed.'
#        end
#      
#        if options[:ids_only]
#          replace @results[:matches].collect { |match|
#            match[:attributes]["sphinx_internal_id"]
#          }
#        else
#          # sellittf patch start # TODO 0501 prevent nil elements, but total_entries is still wrong!
#          replace instances_from_matches.compact
#          # sellittf patch end #
#          add_excerpter
#          add_sphinx_attributes
#          add_matching_fields if client.rank_mode == :fieldmask
#        end
#      end
#    end
#  end

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
