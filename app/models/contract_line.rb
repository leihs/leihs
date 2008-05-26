class ContractLine < DocumentLine
  
  belongs_to :item
  belongs_to :contract

  
  validate :item_model_matching
  

  # custom valid? method
  # returns boolean
  def complete?
    !self.item.nil? and self.valid? and self.available?
  end

  def self.ready_for_contract
    find_by_sql("SELECT u.id AS user_id,
                     u.login AS user_login,
                     sum(cl.quantity) AS quantity,
                     cl.start_date
                  FROM contract_lines cl JOIN contracts c ON cl.contract_id = c.id
                     JOIN users u ON c.user_id = u.id
                  WHERE c.status_const = #{Contract::NEW}
                  GROUP BY cl.start_date, u.id 
                  ORDER BY cl.start_date, u.id")
  end
  
  private
  
  # validator
  def item_model_matching
    errors.add_to_base(_("The item doesn't match with the reserved model")) if !item.nil? and item.model != model
  end
  
  
end

