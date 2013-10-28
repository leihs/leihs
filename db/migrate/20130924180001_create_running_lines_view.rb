class CreateRunningLinesView < ActiveRecord::Migration
  def up

    execute("DROP VIEW IF EXISTS running_lines")

    # we don't recalculate the past
    # if an item is already assigned, we block the availability even if the start_date is in the future
    # if an item is already assigned but not handed over, it's never considered as late even if end_date is in the past
    # we ignore the option_lines
    # we get all lines which are not yet returned
    # we ignore lines that are not handed over which the end_date is already in the past
    execute("CREATE VIEW running_lines AS " \
              "SELECT contract_lines.id, type, contracts.inventory_pool_id, model_id, quantity, start_date, end_date, " \
                "(end_date < CURDATE() AND contracts.status = '#{:signed}') AS is_late, " \
                "IF(item_id IS NOT NULL, CURDATE(), IF(start_date > CURDATE(), start_date, CURDATE())) AS unavailable_from, " \
                "GROUP_CONCAT(groups_users.group_id) AS concat_group_ids " \
              "FROM contract_lines " \
              "INNER JOIN contracts ON contracts.id = contract_lines.contract_id " \
              "LEFT JOIN groups_users ON groups_users.user_id = contracts.user_id " \
              "WHERE type = 'ItemLine' " \
                "AND returned_date IS NULL " \
                "AND contracts.status != '#{:rejected}' " \
                "AND NOT (contracts.status = '#{:unsubmitted}' AND contracts.updated_at < DATE_SUB(UTC_TIMESTAMP(), INTERVAL #{Contract::TIMEOUT_MINUTES} MINUTE)) " \
                "AND NOT (end_date < CURDATE() AND item_id IS NULL) " \
              "GROUP BY contract_lines.id;")

  end

  def down
    execute("DROP VIEW IF EXISTS running_lines")
  end
end
