class RefactorContracts < ActiveRecord::Migration
  def change

    change_table :contract_lines do |t|
      t.belongs_to :inventory_pool
      t.belongs_to :user
      t.belongs_to :delegated_user
      t.belongs_to :handed_over_by_user
    end
    execute "ALTER TABLE contract_lines ADD COLUMN status ENUM('#{ContractLine::STATUSES.join("', '")}') NOT NULL;"

    execute %Q(UPDATE contract_lines AS cl
                INNER JOIN contracts AS c ON cl.contract_id = c.id
               SET cl.inventory_pool_id = c.inventory_pool_id,
                    cl.user_id = c.user_id,
                    cl.delegated_user_id = c.delegated_user_id,
                    cl.handed_over_by_user_id = c.handed_over_by_user_id,
                    cl.status = c.status;)

    change_table :contract_lines do |t|
      t.index :status
      t.foreign_key :inventory_pools
      t.foreign_key :users
      t.foreign_key :users, column: 'delegated_user_id'
      t.foreign_key :users, column: 'handed_over_by_user_id'
    end

    Contract.where.not(status: [:signed, :closed]).joins(:contract_lines).flat_map do |c|
      History.where(target_type: "Contract", target_id: c.id).each do |h|
        c.lines.first.histories << h
      end
    end

    execute %Q(UPDATE contract_lines
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
    # fixing views

    execute("DROP VIEW IF EXISTS visit_lines")
    execute("DROP VIEW IF EXISTS visits")
    execute %Q(CREATE VIEW visits AS
                SELECT HEX( CONCAT_WS( '_', if((status = '#{:signed}'), end_date, start_date), inventory_pool_id, user_id, status)) as id,
                       inventory_pool_id,
                       user_id,
                       status,
                       IF((status = '#{:signed}'), end_date, start_date) AS date,
                       SUM(quantity) AS quantity
                FROM contract_lines
                WHERE status IN ('#{:submitted}', '#{:approved}','#{:signed}')
                GROUP BY user_id, status, date, inventory_pool_id
                ORDER BY date;)

  end
end
