module LeihsAdmin
  module Modules
    module Database
      # TODO: fix module length
      # rubocop:disable Metrics/ModuleLength
      module Consistency
        extend ActiveSupport::Concern
        include Helpers

        # TODO: fix method length & complexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def consistency
          @only_tables_no_views = @connection.execute(
            "SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'")
            .to_h.keys
          @excluded_models = [ReservationsBundle,
                              Audited::Adapters::ActiveRecord::Audit]
          @view_table_models = [PartitionsWithGeneral, Visit]
          @references = []

          Rails.application.eager_load! if Rails.env.development?

          ActiveRecord::Base.descendants.each do |klass|
            next if klass.name =~ /^HABTM_/ or @view_table_models.include? klass
            klass.reflect_on_all_associations(:belongs_to).each do |ref|
              if ref.polymorphic?
                # NOTE we cannot define foreign keys on multiple parent tables
                type_column = "#{ref.name}_type".to_sym
                klass.unscoped
                  .select(type_column)
                  .uniq
                  .pluck(type_column)
                  .compact
                  .flat_map do |target_type|
                  target_klass = target_type.constantize
                  inverse_of = \
                    target_klass.reflect_on_association \
                      klass.name.underscore.pluralize.to_sym
                  dependent = if inverse_of and inverse_of.options[:dependent]
                                inverse_of.options[:dependent]
                              end
                  collect_missing_references(klass,
                                             target_klass.table_name,
                                             klass.table_name,
                                             ref.foreign_key,
                                             target_klass.primary_key,
                                             { type_column => target_type },
                                             true,
                                             dependent)
                end
              else
                if ref.inverse_of and ref.inverse_of.options[:dependent]
                  dependent = ref.inverse_of.options[:dependent]
                end
                collect_missing_references(klass,
                                           ref.table_name,
                                           klass.table_name,
                                           ref.foreign_key,
                                           ref.active_record_primary_key,
                                           nil,
                                           false,
                                           dependent)
              end
            end
          end

          ActiveRecord::Base.descendants.each do |klass|
            klass
              .reflect_on_all_associations(:has_and_belongs_to_many)
              .each do |ref|

              ah = [
                { from_table: ref.join_table,
                  to_table: klass.table_name,
                  from_column: ref.foreign_key,
                  to_column: ref.active_record_primary_key },
                { from_table: ref.join_table,
                  to_table: ref.klass.table_name,
                  from_column: ref.association_foreign_key,
                  to_column: ref.association_primary_key }
              ]

              ah.each do |h|

                if request.delete?
                  next unless h[:from_table] == params[:from_table] and
                    h[:to_table] == params[:to_table] and
                    h[:from_column] == params[:from_column] and
                    h[:to_column] == params[:to_column]
                end

                next if @references.detect do|x|
                  h[:from_table] == x[:from_table] and
                    h[:to_table] == x[:to_table] and
                    h[:from_column] == x[:from_column] and
                    h[:to_column] == x[:to_column]
                end

                query = "SELECT #{h[:from_table]}.* " \
                  "FROM #{h[:from_table]} " \
                  "LEFT JOIN #{h[:to_table]} " \
                  "ON #{h[:from_table]}.#{h[:from_column]} " \
                  "= #{h[:to_table]}.#{h[:to_column]} " \
                  "WHERE #{h[:to_table]}.#{h[:to_column]} IS NULL"

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
              missing_reference[:values]
                .update_all(missing_reference[:from_column] => nil)
            else
              query = missing_reference[:query].gsub(/^SELECT /, 'DELETE ')
              @connection.execute(query)
            end
            redirect_to admin.consistency_path
          end
          # rubocop:enable Metrics/MethodLength
          # rubocop:enable Metrics/CyclomaticComplexity
          # rubocop:enable Metrics/PerceivedComplexity
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end
