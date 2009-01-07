# Patch for rails/activerecord/lib/active_record/serialization.rb
# by Franco Sellitto (sellittf)
# ** 1st**
# provides arguments to :methods, wrapping method name and arguments into an array
# :methods => [:name]
# :methods => [[:name, argument_1, argument_2, ...]]
# ** 2nd**
# provides :records to :include association, generating an intersection between all associated records and desired records
# :include => { :associated_objects => { :records => @only_this_objects } }

module ActiveRecord
  module Serialization
    class Serializer
      
      def serializable_method_names
        Array(options[:methods]).inject([]) do |method_attributes, name_and_arguments| # sellittf
          name_and_arguments = [name_and_arguments] unless name_and_arguments.is_a?(Array) # sellittf
          method_attributes << name_and_arguments if @record.respond_to?(name_and_arguments[0].to_s) # sellittf
          method_attributes
        end
      end

      def serializable_record
        returning(serializable_record = {}) do
          serializable_names.each { |name, *args| serializable_record[name] = @record.send(name, *args) } # sellittf
          add_includes do |association, records, opts|
            scoped_records = opts.delete(:records) # sellittf
            if records.is_a?(Enumerable)
              serializable_record[association] = records.collect { |r| self.class.new(r, opts).serializable_record if scoped_records.nil? or scoped_records.include?(r) }.compact # sellittf
            else
              serializable_record[association] = self.class.new(records, opts).serializable_record if scoped_records.nil? or scoped_records.include?(records) # sellittf
            end
          end
        end
      end
            
      
    end
  end
end
