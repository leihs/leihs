# Patch for rails/activemodel/lib/active_model/serializers/xml.rb
# by Franco Sellitto (sellittf)
# ** 1st**
# provides arguments to :methods, wrapping method name and arguments into an array
# :methods => [:name]
# :methods => [[:name, argument_1, argument_2, ...]]
# ** 2nd**
# provides :records to :include association, generating an intersection between all associated records and desired records
# :include => { :associated_objects => { :records => @only_this_objects } }
=begin
module ActiveModel

  module Serialization
    def serializable_hash(options = nil)
      options ||= {}

      only   = Array.wrap(options[:only]).map(&:to_s)
      except = Array.wrap(options[:except]).map(&:to_s)

      attribute_names = attributes.keys.sort
      if only.any?
        attribute_names &= only
      elsif except.any?
        attribute_names -= except
      end

      # sellittf # start
      #method_names = Array.wrap(options[:methods]).map { |n| n if respond_to?(n.to_s) }.compact
      #Hash[(attribute_names + method_names).map { |n| [n, send(n)] }]
      method_names = Array.wrap(options[:methods]).map do |n|
        if n.is_a?(Array)
          n if respond_to?(n.shift.to_s)
        else
          n if respond_to?(n.to_s)
        end
      end.compact
      
      Hash[(attribute_names + method_names).map do |n|
        if n.is_a?(Array)
          method_name = n.shift
          method_arguments = n
          [method_name, send(method_name, method_arguments)]
        else
          [n, send(n)]
        end
      end]
      # sellittf # end
      
    end
  end

#=begin
  module Serializers
    module Xml
      class Serializer

        # sellittf
        def serializable_methods
          Array.wrap(options[:methods]).map do |name|
            if name.is_a?(Array)
              method_name = name.shift.to_s
              method_arguments = name 
              self.class::MethodAttribute.new(method_name, @serializable, method_arguments) if @serializable.respond_to?(method_name)
            else
              self.class::MethodAttribute.new(name.to_s, @serializable) if @serializable.respond_to?(name.to_s)
            end
          end.compact
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
#=end

end
=end