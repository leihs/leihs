class RemoveFkIndices < ActiveRecord::Migration

  # Remove old foreign key remains
  def self.up

    # MySQL and ActiveRecord produce problems with each other:
    # http://lists.mysql.com/mysql/204151
    # http://lists.mysql.com/mysql/204199
    # http://bugs.mysql.com/bug.php?id=10333
    # AR seems to guess the wrong foreign key name, which it can't remove.

    execute "ALTER TABLE contract_lines DROP FOREIGN KEY fk_contract_lines_contract_id"
    execute "ALTER TABLE contract_lines DROP KEY fk_contract_lines_contract_id"

    execute "ALTER TABLE contract_lines DROP FOREIGN KEY fk_contract_lines_item_id"
    execute "ALTER TABLE contract_lines DROP KEY fk_contract_lines_item_id"

    execute "ALTER TABLE contract_lines DROP FOREIGN KEY fk_contract_lines_model_id"
    execute "ALTER TABLE contract_lines DROP KEY fk_contract_lines_model_id"

    execute "ALTER TABLE contract_lines DROP FOREIGN KEY fk_contract_lines_option_id"

    # use default name for indices
    change_table :contract_lines do |t|
      t.index :contract_id
      t.index :item_id
      t.index :model_id
    end
  end

  def self.down
  end
end
