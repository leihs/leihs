module NestedHasManyThrough
  module Reflection # :nodoc:
    def self.included(base)
      base.send :alias_method_chain, :check_validity!, :nested_has_many_through
    end
  
    def check_validity_with_nested_has_many_through!
      check_validity_without_nested_has_many_through!
    rescue ActiveRecord::HasManyThroughSourceAssociationMacroError => e
      # now we permit has many through to a :though source
      raise e unless source_reflection.options[:through]
    end
  end
  
  module Association
    def self.included(base)
      base.class_eval do
        def construct_conditions
          @nested_join_attributes ||= construct_nested_join_attributes
          "#{@nested_join_attributes[:remote_key]} = #{@owner.quoted_id} #{@nested_join_attributes[:conditions]}"
        end

        def construct_joins(custom_joins = nil)
          @nested_join_attributes ||= construct_nested_join_attributes
          "#{@nested_join_attributes[:joins]} #{custom_joins}"
        end

        def construct_owner_attributes(reflection)
          return {} if reflection.through_reflection
          if as = reflection.options[:as]
            { "#{as}_id" => @owner.id,
              "#{as}_type" => @owner.class.base_class.name.to_s }
          else
            { reflection.primary_key_name => @owner.id }
          end
        end

        def <<(*records)
          return if records.empty?
          through = @reflection.through_reflection
          raise ActiveRecord::HasManyThroughCantAssociateNewRecords.new(@owner, through) if @owner.new_record?

          target_class = through.klass
          target_class.transaction do
            flatten_deeper(records).each do |associate|
              raise_on_type_mismatch(associate)
              raise ActiveRecord::HasManyThroughCantAssociateNewRecords.new(@owner, through) unless associate.respond_to?(:new_record?) && !associate.new_record?

              create_scope_hash = {}
              callback(:before_add, associate, create_scope_hash)
              associate_parent = target_class.send(:with_scope, :create => create_scope_hash.merge(construct_join_attributes(associate))) { target_class.create! }
              @owner.send(@reflection.through_reflection.name) << associate_parent
              callback(:after_add, associate, associate_parent)
              
              @target << associate if loaded?
            end
          end
          self
        end

        def delete(*records)
          through = @reflection.through_reflection
          raise ActiveRecord::HasManyThroughCantDissociateNewRecords.new(@owner, through) if @owner.new_record?

          load_target
          klass = through.klass
          klass.transaction do
            flatten_deeper(records).each do |associate|
              raise_on_type_mismatch(associate)
              raise ActiveRecord::HasManyThroughCantDissociateNewRecords.new(@owner, through) unless associate.respond_to?(:new_record?) && !associate.new_record?
              callback(:before_remove, associate)
              @owner.send(through.name).proxy_target.delete(klass.delete_all(construct_join_attributes(associate)))
              callback(:after_remove, associate)
              @target.delete(associate)
            end
          end
          self
        end

        private
        
        #In case this gets pulled into rails edge, we should probably consider extending AssociationCollection insteed on AssociationProxy
        #this is copied from Rails code base, so not specing this out.
        def callback(method, *args)
          callbacks_for(method).each do |callback|
            case callback
              when Symbol
                @owner.send(callback, *args)
              when Proc, Method
                callback.call(@owner, *args)
              else
                if callback.respond_to?(method)
                  callback.send(method, @owner, *args)
                else
                  raise ActiveRecordError, "Callbacks must be a symbol denoting the method to call, a string to be evaluated, a block to be invoked, or an object responding to the callback method."
                end
            end
          end
        end

        def callbacks_for(callback_name)
          full_callback_name = "#{callback_name}_for_#{@reflection.name}"
          @owner.class.read_inheritable_attribute(full_callback_name.to_sym) || []
        end
      end
    end

  protected    
    # Given any belongs_to or has_many (including has_many :through) association,
    # return the essential components of a join corresponding to that association, namely:
    #
    # * <tt>:joins</tt>: any additional joins required to get from the association's table
    #   (reflection.table_name) to the table that's actually joining to the active record's table
    # * <tt>:remote_key</tt>: the name of the key in the join table (qualified by table name) which will join
    #   to a field of the active record's table
    # * <tt>:local_key</tt>: the name of the key in the local table (not qualified by table name) which will
    #   take part in the join
    # * <tt>:conditions</tt>: any additional conditions (e.g. filtering by type for a polymorphic association,
    #    or a :conditions clause explicitly given in the association), including a leading AND
    def construct_nested_join_attributes( reflection = @reflection, 
                                          association_class = reflection.klass,
                                          table_ids = {association_class.table_name => 1})
      if reflection.through_reflection
        construct_has_many_through_attributes(reflection, table_ids)
      else
        construct_has_many_or_belongs_to_attributes(reflection, association_class, table_ids)
      end
    end
    
    def construct_has_many_through_attributes(reflection, table_ids)
      # Construct the join components of the source association, so that we have a path from
      # the eventual target table of the association up to the table named in :through, and
      # all tables involved are allocated table IDs.
      source_attrs = construct_nested_join_attributes(reflection.source_reflection, reflection.klass, table_ids)
      
      # Determine the alias of the :through table; this will be the last table assigned
      # when constructing the source join components above.
      through_table_alias = through_table_name = reflection.through_reflection.table_name
      through_table_alias += "_#{table_ids[through_table_name]}" unless table_ids[through_table_name] == 1

      # Construct the join components of the through association, so that we have a path to
      # the active record's table.
      through_attrs = construct_nested_join_attributes(reflection.through_reflection, reflection.through_reflection.klass, table_ids)

      # Any subsequent joins / filters on owner attributes will act on the through association,
      # so that's what we return for the conditions/keys of the overall association.
      conditions = through_attrs[:conditions]
      conditions += " AND #{interpolate_sql(reflection.klass.send(:sanitize_sql, reflection.options[:conditions]))}" if reflection.options[:conditions]
      
      {
        :joins => "%s INNER JOIN %s ON ( %s = %s.%s %s) %s %s" % [
          source_attrs[:joins],
          through_table_name == through_table_alias ? through_table_name : "#{through_table_name} #{through_table_alias}",
          source_attrs[:remote_key],
          through_table_alias, source_attrs[:local_key],
          source_attrs[:conditions],
          through_attrs[:joins],
          reflection.options[:joins]
        ],
        :remote_key => through_attrs[:remote_key],
        :local_key => through_attrs[:local_key],
        :conditions => conditions
      }
    end
    
    
    # reflection is not has_many :through; it's a standard has_many / belongs_to instead
    # TODO: see if we can defer to rails code here a bit more
    def construct_has_many_or_belongs_to_attributes(reflection, association_class, table_ids)
      # Determine the alias used for remote_table_name, if any. In all cases this will already
      # have been assigned an ID in table_ids (either through being involved in a previous join,
      # or - if it's the first table in the query - as the default value of table_ids)
      remote_table_alias = remote_table_name = association_class.table_name
      remote_table_alias += "_#{table_ids[remote_table_name]}" unless table_ids[remote_table_name] == 1

      # Assign a new alias for the local table.
      local_table_alias = local_table_name = reflection.active_record.table_name
      if table_ids[local_table_name]
        table_id = table_ids[local_table_name] += 1
        local_table_alias += "_#{table_id}"
      else
        table_ids[local_table_name] = 1
      end
      
      conditions = ''
      # Add filter for single-table inheritance, if applicable.
      conditions += " AND #{remote_table_alias}.#{association_class.inheritance_column} = #{association_class.quote_value(association_class.name.demodulize)}" unless association_class.descends_from_active_record?
      # Add custom conditions
      conditions += " AND (#{interpolate_sql(association_class.send(:sanitize_sql, reflection.options[:conditions]))})" if reflection.options[:conditions]
      
      if reflection.macro == :belongs_to
        if reflection.options[:polymorphic]
          conditions += " AND #{local_table_alias}.#{reflection.options[:foreign_type]} = #{reflection.active_record.quote_value(association_class.base_class.name.to_s)}"
        end
        {
          :joins => reflection.options[:joins],
          :remote_key => "#{remote_table_alias}.#{association_class.primary_key}",
          :local_key => reflection.primary_key_name,
          :conditions => conditions
        }
      else
        # Association is has_many (without :through)
        if reflection.options[:as]
          conditions += " AND #{remote_table_alias}.#{reflection.options[:as]}_type = #{reflection.active_record.quote_value(reflection.active_record.base_class.name.to_s)}"
        end
        {
          :joins => "#{reflection.options[:joins]}",
          :remote_key => "#{remote_table_alias}.#{reflection.primary_key_name}",
          :local_key => reflection.klass.primary_key,
          :conditions => conditions
        }
      end
    end
  end
end