#### source: https://tomafro.net/2009/09/quickly-list-missing-foreign-key-indexes
#
# c = ActiveRecord::Base.connection
# c.tables.collect do |t|
#  columns = \
#    c.columns(t)
#      .collect(&:name)
#      .select {|x| x.ends_with?("_id" || x.ends_with("_type"))}
#  indexed_columns = c.indexes(t).collect(&:columns).flatten.uniq
#  unindexed = columns - indexed_columns
#  unless unindexed.empty?
#    puts "#{t}: #{unindexed.join(", ")}"
#  end
# end

module LeihsAdmin
  class DatabaseController < AdminController
    include Modules::Database::Consistency

    before_action do
      @connection = ActiveRecord::Base.connection
    end

    def indexes
      @indexes_found, @indexes_not_found = begin
        Modules::Database::INDEXES.partition do |table, columns, options|
          indexes = @connection.indexes(table)
          index = indexes.detect { |x| x.columns == columns }
          if not index
            false
          elsif options.blank?
            true
          else
            index.unique == !options[:unique].nil?
          end
        end
      end
    end

    def empty_columns
      if request.delete?
        nullify_empty_columns
      end

      @empty_columns = {}
      @connection.tables.each do |table_name|
        @connection
          .columns(table_name)
          .select { |c| c.type == :string and c.null }
          .each do |column|
          r = @connection.execute(
            "SELECT * FROM `#{table_name}` WHERE `#{column.name}` REGEXP '^\ *$'")
            .to_a
          next if r.empty?
          @empty_columns[[table_name, column.name]] = r
        end
      end
    end

    def access_rights
      @visits = \
        Visit.joins('LEFT JOIN access_rights ' \
                    'ON reservations.user_id = access_rights.user_id ' \
                    'AND reservations.inventory_pool_id = ' \
                    'access_rights.inventory_pool_id')
          .where(access_rights: { id: nil })
          .order(:inventory_pool_id, :user_id, :date)
          .group('reservations.inventory_pool_id, reservations.user_id')
          .includes(:user, :inventory_pool)
      if request.post?
        @visits.each do |visit|
          visit
            .inventory_pool
            .access_rights
            .find_or_create_by(user: visit.user, role: :customer)
        end
        @visits.reload
      end
    end

    private

    def nullify_empty_columns
      only_tables_no_views = \
        @connection \
          .execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'")
          .to_h
          .keys
      only_tables_no_views.each do |table_name|
        @connection
          .columns(table_name)
          .select { |c| c.type == :string and c.null }
          .each do |column|
          @connection.execute \
            %(UPDATE `#{table_name}`
                SET `#{column.name}` = NULL WHERE `#{column.name}` REGEXP '^\ *$')
        end
      end
    end

  end
end
