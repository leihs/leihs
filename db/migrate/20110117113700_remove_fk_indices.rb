class RemoveFkIndices < ActiveRecord::Migration

  # Remove old foreign key remains
  def self.up

    # MySQL and ActiveRecord produce problems with each other:
    # http://lists.mysql.com/mysql/204151
    # http://lists.mysql.com/mysql/204199
    # http://bugs.mysql.com/bug.php?id=10333
    # AR seems to guess the wrong foreign key name, which it can't remove.
    sql = ContractLine.connection.execute("show create table contract_lines")
    schema = sql.fetch_row[1]
    
    keys_to_check = ["fk_contract_lines_contract_id", "fk_contract_lines_item_id", "fk_contract_lines_model_id", "fk_contract_lines_option_id"]
    
    keys_to_check.each do |k|
      if schema.include?(k)
        execute "ALTER TABLE contract_lines DROP FOREIGN KEY #{k}"
        execute "ALTER TABLE contract_lines DROP KEY #{k}"
        field_name = k.gsub("fk_contract_lines_","")
        change_table :contract_lines do |t|
          t.index field_name
        end
      end
    end
  end

  def self.down
  end
end
