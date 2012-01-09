class CreateVisitsView < ActiveRecord::Migration
  def up
    
    execute("DROP VIEW IF EXISTS visit_lines")
    # acting as join table, column 'visit_id' is needed by the association
    execute("CREATE VIEW visit_lines AS " \
              "SELECT " \
                "CAST( CONCAT( UNIX_TIMESTAMP( IF(status_const = #{Contract::UNSIGNED}, start_date, end_date)), " \
                " inventory_pool_id, user_id, status_const) AS UNSIGNED) as visit_id, " \
                "inventory_pool_id, user_id, status_const, " \
                "IF(status_const = #{Contract::UNSIGNED}, 'hand_over', 'take_back') AS action, " \
                "IF(status_const = #{Contract::UNSIGNED}, start_date, end_date) AS date, " \
                "quantity, cl.id AS contract_line_id " \
              "FROM contract_lines AS cl INNER JOIN contracts AS c ON cl.contract_id = c.id " \
              "WHERE status_const IN (#{Contract::UNSIGNED}, #{Contract::SIGNED}) " \
                "AND cl.returned_date IS NULL " \
              "ORDER BY date;")
    
    
    execute("DROP VIEW IF EXISTS visits")
    # column 'id' is needed by the eager-loader and the identity-map
    execute("CREATE VIEW visits AS " \
              "SELECT " \
                "CAST( CONCAT( UNIX_TIMESTAMP(date), inventory_pool_id, user_id, status_const) AS UNSIGNED) as id, " \
                "inventory_pool_id, user_id, status_const, action, date, " \
                "SUM(quantity) AS quantity " \
              "FROM visit_lines " \
              "GROUP BY user_id, status_const, date, inventory_pool_id;")

  end

  def down
    execute("DROP VIEW IF EXISTS visits")
    execute("DROP VIEW IF EXISTS visit_lines")
  end
end
