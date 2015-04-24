class RefactorContracts < ActiveRecord::Migration
  def change

    execute("DROP VIEW IF EXISTS visit_lines")
    execute("DROP VIEW IF EXISTS visits")

    ############################################################

    # NOTE too slow: rename_table :contract_lines, :reservations
    execute("RENAME TABLE contract_lines TO reservations;")

    change_table :reservations do |t|
      t.belongs_to :inventory_pool
      t.belongs_to :user
      t.belongs_to :delegated_user
      t.belongs_to :handed_over_by_user
    end
    execute "ALTER TABLE reservations ADD COLUMN status ENUM('#{Reservation::STATUSES.join("', '")}') NOT NULL;"

    execute %Q(UPDATE reservations AS r
                INNER JOIN contracts AS c ON r.contract_id = c.id
               SET r.inventory_pool_id = c.inventory_pool_id,
                    r.user_id = c.user_id,
                    r.delegated_user_id = c.delegated_user_id,
                    r.handed_over_by_user_id = c.handed_over_by_user_id,
                    r.status = IF(r.returned_date IS NULL, c.status, '#{:closed}');)

    change_table :reservations do |t|
      t.index :status
      t.foreign_key :inventory_pools
      t.foreign_key :users
      t.foreign_key :users, column: 'delegated_user_id'
      t.foreign_key :users, column: 'handed_over_by_user_id'
    end

    Contract.where.not(status: [:signed, :closed]).joins(:reservations).flat_map do |c|
      History.where(target_type: "Contract", target_id: c.id).each do |h|
        c.reservations.first.histories << h
      end
    end

    execute %Q(UPDATE reservations
               SET contract_id = NULL
               WHERE status NOT IN ('#{:signed}', '#{:closed}');)

    execute %Q(DELETE FROM contracts WHERE status NOT IN ('#{:signed}', '#{:closed}');)

    change_table :contracts do |t|
      t.remove_foreign_key :inventory_pools
      t.remove_foreign_key :users
      t.remove_foreign_key column: 'delegated_user_id'
      t.remove_foreign_key column: 'handed_over_by_user_id'
      t.remove :inventory_pool_id
      t.remove :user_id
      t.remove :delegated_user_id
      t.remove :handed_over_by_user_id
      t.remove :status
    end


    ############################################################

    execute %Q(CREATE VIEW visits AS
                SELECT HEX( CONCAT_WS( '_', if((status = '#{:signed}'), end_date, start_date), inventory_pool_id, user_id, status)) as id,
                       inventory_pool_id,
                       user_id,
                       status,
                       IF((status = '#{:signed}'), end_date, start_date) AS date,
                       SUM(quantity) AS quantity
                FROM reservations
                WHERE status IN ('#{:submitted}', '#{:approved}','#{:signed}')
                GROUP BY user_id, status, date, inventory_pool_id
                ORDER BY date;)

  end
end
