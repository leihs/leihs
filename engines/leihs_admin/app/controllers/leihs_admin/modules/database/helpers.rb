module LeihsAdmin
  module Modules
    module Database
      module Helpers
        # TODO: fix method length & complexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def collect_missing_references(klass,
                                       other_table,
                                       this_table,
                                       this_column,
                                       other_column,
                                       additional_where = nil,
                                       polymorphic = false,
                                       dependent = nil)
          # NOTE we skip references on sql-views
          return if @excluded_models.include?(klass) \
            or not @only_tables_no_views.include?(this_table) \
            or not @only_tables_no_views.include?(other_table)

          h = { from_table: this_table,
                to_table: other_table,
                from_column: this_column,
                to_column: other_column }

          if request.delete?
            return unless h[:from_table] == params[:from_table] and
                h[:to_table] == params[:to_table] and
                h[:from_column] == params[:from_column] and
                h[:to_column] == params[:to_column]
          end

          return if @references.detect do|x|
                      h[:from_table] == x[:from_table] and
              h[:to_table] == x[:to_table] and
              h[:from_column] == x[:from_column] and
              h[:to_column] == x[:to_column]
          end

          r = left_join_query(klass,
                              other_table,
                              this_table,
                              this_column,
                              other_column,
                              additional_where)

          @references << h.merge(query: r.to_sql,
                                 values: r,
                                 polymorphic: polymorphic,
                                 dependent: dependent)
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity

        def left_join_query(klass,
                            other_table,
                            this_table,
                            this_column,
                            other_column,
                            additional_where)
          r = klass.unscoped
              .joins(
                format('LEFT JOIN %s AS t2 ON %s.%s = t2.%s',
                       other_table, this_table, this_column, other_column)
              )
              .where.not(this_column => nil)
              .where(t2: { other_column => nil })
          r = r.where(additional_where) if additional_where
          r
        end

      end
    end
  end
end
