class CreateVisitsView < ActiveRecord::Migration
  def up
    execute("CREATE VIEW visits AS " \
              "SELECT inventory_pool_id, user_id, status_const, " \
                "IF(status_const = #{Contract::UNSIGNED}, 'hand_over', 'take_back') AS action, " \
                "IF(status_const = #{Contract::UNSIGNED}, start_date, end_date) AS date, " \
                "SUM(quantity) AS quantity, " \
                "GROUP_CONCAT(cl.id) AS contract_line_ids " \
              "FROM contract_lines AS cl INNER JOIN contracts AS c ON cl.contract_id = c.id " \
              "WHERE status_const IN (#{Contract::UNSIGNED}, #{Contract::SIGNED}) " \
                "AND cl.returned_date IS NULL " \
              "GROUP BY user_id, status_const, date, inventory_pool_id " \
              "ORDER BY date;")
  end

  def down
    execute("DROP VIEW IF EXISTS visits")
  end
end
