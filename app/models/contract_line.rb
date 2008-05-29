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
  def self.ready_for_hand_over(user = nil)
    ready_for_('start_date', Contract::NEW, user)
  end

  def self.ready_for_take_back(user = nil)
    ready_for_('end_date', Contract::SIGNED, user)
  end

  def self.ready_for_remind(user = nil)
    ready_for_('end_date', Contract::SIGNED, user, true)
  end
##################################################
  
  def order_to_exclude
    0
  end
  
  def contract_to_exclude
    id
  end  
  
  private

  def self.ready_for_(date, status, user, remind = false)
    where_user = user ? " AND u.id = #{user.id}" : ""
    where_remind = remind ? " AND cl.end_date < CURDATE() " : ""

    find_by_sql("SELECT u.id AS user_id,
                     u.login AS user_login,
                     SUM(cl.quantity) AS quantity,
                     cl.#{date}
                  FROM contract_lines cl JOIN contracts c ON cl.contract_id = c.id
                     JOIN users u ON c.user_id = u.id
                  WHERE c.status_const = #{status}
                    AND cl.returned_date IS NULL
                    #{where_user}
                    #{where_remind}
                  GROUP BY cl.#{date}, u.id 
                  ORDER BY cl.#{date}, u.id")
  end
    
  # validator
  def item_model_matching
    errors.add_to_base(_("The item doesn't match with the reserved model")) if item and item.model != model
  end
  
  def item_available
    errors.add_to_base(_("The item is already handed over")) if item and ContractLine.exists?(["id != ? AND item_id = ? AND returned_date IS NULL", id, item.id]) 
  end
  
  
end

