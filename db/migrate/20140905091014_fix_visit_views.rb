class FixVisitViews < ActiveRecord::Migration
  def change
    execute("DROP VIEW IF EXISTS visit_lines")
    # acting as join table, column 'visit_id' is needed by the association
    execute("CREATE VIEW visit_lines AS " \
              "SELECT " \
                "HEX( CONCAT_WS( '_', IF( status = '#{:approved}', start_date, end_date), " \
                " inventory_pool_id, user_id, status)) as visit_id, " \
                "inventory_pool_id, user_id, delegated_user_id, status, " \
                "IF(status = '#{:approved}', 'hand_over', 'take_back') AS action, " \
                "IF(status = '#{:approved}', start_date, end_date) AS date, " \
                "quantity, cl.id AS contract_line_id " \
              "FROM contract_lines AS cl INNER JOIN contracts AS c ON cl.contract_id = c.id " \
              "WHERE status IN ('#{:approved}', '#{:signed}') " \
                "AND cl.returned_date IS NULL " \
              "ORDER BY date;")

    execute("DROP VIEW IF EXISTS visits")
    execute("CREATE VIEW visits AS " \
            "SELECT " \
              "HEX( CONCAT_WS( '_', date, inventory_pool_id, user_id, status)) as id, " \
              "inventory_pool_id, user_id, status, action, date, " \
              "SUM(quantity) AS quantity " \
            "FROM visit_lines " \
            "GROUP BY user_id, status, date, inventory_pool_id;")
  end
end
