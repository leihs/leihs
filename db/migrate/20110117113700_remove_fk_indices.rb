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
    schema.gsub!("`","") # Remove those ugly backticks from around field names
    
    constraints = schema.split("\n").select{|l|
                                            l =~ /^\s+CONSTRAINT/
                                           }
    keys_to_check = ["fk_contract_lines_contract_id", "fk_contract_lines_item_id", "fk_contract_lines_model_id", "fk_contract_lines_option_id"]
    
    keys_to_check.each do |k|
      # The constraint exists in this table description -- so we can safely kill it. Otherwise
      # MySQL throws a hissy fit.
      unless constraints.select{|c|
                            c =~ /^\s+CONSTRAINT #{k}/
                           }.empty?
        execute "ALTER TABLE contract_lines DROP FOREIGN KEY #{k}"
        
        # That last one is a special case
        unless k == "fk_contract_lines_option_id"
          execute "ALTER TABLE contract_lines DROP KEY #{k}" 
          field_name = k.gsub("fk_contract_lines_","")
          change_table :contract_lines do |t|
            t.index field_name
          end
        end # /inner unless
        
      end # /outer unless
      
    end # /keys_to_check.each
  end

  def self.down
  end
end
