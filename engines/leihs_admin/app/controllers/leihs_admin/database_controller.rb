#### source: https://tomafro.net/2009/09/quickly-list-missing-foreign-key-indexes
#
#c = ActiveRecord::Base.connection
#c.tables.collect do |t|
#  columns = c.columns(t).collect(&:name).select {|x| x.ends_with?("_id" || x.ends_with("_type"))}
#  indexed_columns = c.indexes(t).collect(&:columns).flatten.uniq
#  unindexed = columns - indexed_columns
#  unless unindexed.empty?
#    puts "#{t}: #{unindexed.join(", ")}"
#  end
#end

module LeihsAdmin
  class DatabaseController < AdminController

    before_filter do
      @connection = ActiveRecord::Base.connection
    end

    def indexes
      @indexes_found, @indexes_not_found = begin
        [
            ['access_rights', ['deleted_at']],
            ['access_rights', ['inventory_pool_id']],
            ['access_rights', ['suspended_until']],
            ['access_rights', ['user_id', 'inventory_pool_id', 'deleted_at']],
            ['accessories', ['model_id']],
            ['accessories_inventory_pools', ['accessory_id', 'inventory_pool_id'], unique: true],
            ['accessories_inventory_pools', ['inventory_pool_id']],
            ['addresses', ['street', 'zip_code', 'city', 'country_code'], unique: true],
            ['attachments', ['model_id']],
            ['audits', ['auditable_id', 'auditable_type']],
            ['audits', ['associated_id', 'associated_type']],
            ['audits', ['user_id', 'user_type']],
            ['audits', ['request_uuid']],
            ['audits', ['created_at']],
            ['reservations', ['status']],
            ['reservations', ['inventory_pool_id']],
            ['reservations', ['user_id']],
            ['reservations', ['delegated_user_id']],
            ['reservations', ['handed_over_by_user_id']],
            ['reservations', ['contract_id']],
            ['reservations', ['end_date']],
            ['reservations', ['item_id']],
            ['reservations', ['model_id']],
            ['reservations', ['option_id']],
            ['reservations', ['returned_date', 'contract_id']],
            ['reservations', ['start_date']],
            ['reservations', ['type', 'contract_id']],
            ['groups', ['inventory_pool_id']],
            ['groups_users', ['group_id']],
            ['groups_users', ['user_id', 'group_id'], unique: true],
            ['holidays', ['inventory_pool_id']],
            ['holidays', ['start_date', 'end_date']],
            ['images', ['target_id', 'target_type']],
            ['inventory_pools', ['name'], unique: true],
            ['inventory_pools_model_groups', ['inventory_pool_id']],
            ['inventory_pools_model_groups', ['model_group_id']],
            ['items', ['inventory_code'], unique: true],
            ['items', ['inventory_pool_id']],
            ['items', ['is_borrowable']],
            ['items', ['is_broken']],
            ['items', ['is_incomplete']],
            ['items', ['location_id']],
            ['items', ['model_id', 'retired', 'inventory_pool_id']],
            ['items', ['owner_id']],
            ['items', ['parent_id', 'retired']],
            ['items', ['retired']],
            ['languages', ['active', 'default']],
            ['languages', ['name'], unique: true],
            ['locations', ['building_id']],
            ['model_group_links', ['ancestor_id']],
            ['model_group_links', ['descendant_id', 'ancestor_id', 'direct']],
            ['model_group_links', ['direct']],
            ['model_groups', ['type']],
            ['model_links', ['model_group_id', 'model_id']],
            ['model_links', ['model_id', 'model_group_id']],
            ['models', ['is_package']],
            ['models_compatibles', ['compatible_id']],
            ['models_compatibles', ['model_id']],
            ['notifications', ['user_id']],
            ['notifications', ['created_at', 'user_id']],
            ['options', ['inventory_pool_id']],
            ['partitions', ['model_id', 'inventory_pool_id', 'group_id'], unique: true],
            ['properties', ['model_id']],
            ['users', ['authentication_system_id']],
            ['workdays', ['inventory_pool_id']]
        ].partition do |table, columns, options|
          indexes = @connection.indexes(table)
          index = indexes.detect { |x| x.columns == columns }
          if not index
            false
          elsif options.blank?
            true
          else
            index.unique == !!options[:unique]
          end
        end
      end
    end

    def empty_columns
      if request.delete?
        only_tables_no_views = @connection.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'").to_h.keys
        only_tables_no_views.each do |table_name|
          @connection.columns(table_name).select{|c| c.type == :string and c.null }.each do |column|
            @connection.execute %Q(UPDATE `#{table_name}` SET `#{column.name}` = NULL WHERE `#{column.name}` REGEXP '^\ *$')
          end
        end
      end

      @empty_columns = {}
      @connection.tables.each do |table_name|
        @connection.columns(table_name).select { |c| c.type == :string and c.null }.each do |column|
          r = @connection.execute(%Q(SELECT * FROM `#{table_name}` WHERE `#{column.name}` REGEXP '^\ *$')).to_a
          next if r.empty?
          @empty_columns[[table_name, column.name]] = r
        end
      end
    end

    def access_rights
      @visits = Visit.joins('LEFT JOIN access_rights ON visits.user_id = access_rights.user_id AND visits.inventory_pool_id = access_rights.inventory_pool_id').
          where(access_rights: {id: nil}).
          order(:inventory_pool_id, :user_id, :date).
          group('visits.inventory_pool_id, visits.user_id').
          includes(:user, :inventory_pool)
      if request.post?
        @visits.each do |visit|
          visit.inventory_pool.access_rights.create(user: visit.user, role: :customer)
        end
        @visits.reload
      end
    end

    def consistency
      @only_tables_no_views = @connection.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'").to_h.keys
      @excluded_models = [ReservationsBundle, Audited::Adapters::ActiveRecord::Audit]
      @view_table_models = [PartitionsWithGeneral, Visit]

      @references = []

      def collect_missing_references(klass, other_table, this_table, this_column, other_column, additional_where = nil, polymorphic = false, dependent = nil)
        # NOTE we skip references on sql-views
        return if @excluded_models.include?(klass) or not @only_tables_no_views.include?(this_table) or not @only_tables_no_views.include?(other_table)

        h = {from_table: this_table,
             to_table: other_table,
             from_column: this_column,
             to_column: other_column}

        if request.delete?
          return unless h[:from_table] == params[:from_table] and
              h[:to_table] == params[:to_table] and
              h[:from_column] == params[:from_column] and
              h[:to_column] == params[:to_column]
        end

        return if @references.detect {|x| h[:from_table] == x[:from_table] and
            h[:to_table] == x[:to_table] and
            h[:from_column] == x[:from_column] and
            h[:to_column] == x[:to_column]  }

        r = left_join_query(klass, other_table, this_table, this_column, other_column, additional_where)

        @references << h.merge(query: r.to_sql,
                               values: r,
                               polymorphic: polymorphic,
                               dependent: dependent)
      end

      Rails.application.eager_load! if Rails.env.development?

      ActiveRecord::Base.descendants.each do |klass|
        next if klass.name =~ /^HABTM_/ or @view_table_models.include? klass
        klass.reflect_on_all_associations(:belongs_to).each do |ref|
          if ref.polymorphic?
            # NOTE we cannot define foreign keys on multiple parent tables
            type_column = "#{ref.name}_type".to_sym
            klass.unscoped.select(type_column).uniq.pluck(type_column).compact.flat_map do |target_type|
              target_klass = target_type.constantize
              inverse_of = target_klass.reflect_on_association(klass.name.underscore.pluralize.to_sym)
              dependent = if inverse_of and inverse_of.options[:dependent]
                            inverse_of.options[:dependent]
                          else
                            nil
                          end
              collect_missing_references(klass, target_klass.table_name, klass.table_name, ref.foreign_key, target_klass.primary_key, {type_column => target_type}, true, dependent)
            end
          else
            dependent = if ref.inverse_of and ref.inverse_of.options[:dependent]
                          ref.inverse_of.options[:dependent]
                        else
                          nil
                        end
            collect_missing_references(klass, ref.table_name, klass.table_name, ref.foreign_key, ref.active_record_primary_key, nil, false, dependent)
          end
        end
      end

      ActiveRecord::Base.descendants.each do |klass|
        klass.reflect_on_all_associations(:has_and_belongs_to_many).each do |ref|

          ah = [
              {from_table: ref.join_table,
               to_table: klass.table_name,
               from_column: ref.foreign_key,
               to_column: ref.active_record_primary_key},
              {from_table: ref.join_table,
               to_table: ref.klass.table_name,
               from_column: ref.association_foreign_key,
               to_column: ref.association_primary_key}
          ]

          ah.each do |h|

            if request.delete?
              next unless h[:from_table] == params[:from_table] and
                  h[:to_table] == params[:to_table] and
                  h[:from_column] == params[:from_column] and
                  h[:to_column] == params[:to_column]
            end

            next if @references.detect {|x| h[:from_table] == x[:from_table] and
                h[:to_table] == x[:to_table] and
                h[:from_column] == x[:from_column] and
                h[:to_column] == x[:to_column]  }

            query = "SELECT #{h[:from_table]}.* FROM #{h[:from_table]} LEFT JOIN #{h[:to_table]} ON #{h[:from_table]}.#{h[:from_column]}=#{h[:to_table]}.#{h[:to_column]} WHERE #{h[:to_table]}.#{h[:to_column]} IS NULL"

            @references << h.merge(query: query,
                                   values: @connection.execute(query).to_a,
                                   polymorphic: false,
                                   dependent: nil,
                                   join_table: true)

          end
        end
      end

      if request.delete? and @references.size == 1
        missing_reference = @references.first

        case params[:dependent].try :to_sym
          when :delete_all, :delete
            missing_reference[:values].delete_all
          when :destroy
            missing_reference[:values].readonly(false).destroy_all
          when :nullify
            missing_reference[:values].update_all(missing_reference[:from_column] => nil)
          else
            query = missing_reference[:query].gsub(/^SELECT /, 'DELETE ')
            @connection.execute(query)
        end
        redirect_to admin.consistency_path
      end

    end

    private

    def left_join_query(klass, other_table, this_table, this_column, other_column, additional_where)
      r = klass.unscoped.
          joins('LEFT JOIN %s AS t2 ON %s.%s = t2.%s' % [other_table, this_table, this_column, other_column]).
          where.not(this_column => nil).
          where(t2: {other_column => nil})
      r = r.where(additional_where) if additional_where
      r
    end

  end

end
