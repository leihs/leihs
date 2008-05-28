class ContractLine < DocumentLine
  
  belongs_to :item
  belongs_to :contract

  
  validate :item_model_matching, :item_available
  

  # custom valid? method
  # returns boolean
  def complete?
    !self.item.nil? and self.valid? and self.available?
  end

##################################################
  def self.ready_for_hand_over
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

  def self.ready_for_take_back
    find_by_sql("SELECT u.id AS user_id,
                     u.login AS user_login,
                     sum(cl.quantity) AS quantity,
                     cl.end_date
                  FROM contract_lines cl JOIN contracts c ON cl.contract_id = c.id
                     JOIN users u ON c.user_id = u.id
                  WHERE c.status_const = #{Contract::SIGNED}
                  GROUP BY cl.end_date, u.id 
                  ORDER BY cl.end_date, u.id")
  end
##################################################
  
  def order_to_exclude
    0
  end
  
  def contract_to_exclude
    id
  end  
  
  private
  
  # validator
  def item_model_matching
    errors.add_to_base(_("The item doesn't match with the reserved model")) if item and item.model != model
  end
  
  def item_available
    errors.add_to_base(_("The item is already handed over")) if item and ContractLine.exists?(["id != ? AND item_id = ? AND returned_date IS NULL", id, item.id]) 
  end
  
  
end

