class ContractLine < DocumentLine
  
  belongs_to :contract
  belongs_to :location
  
  delegate :inventory_pool, :to => :contract
  
  validate :inventory_pool_open
  
##################################################

  named_scope :to_take_back,  :conditions => ["(item_id IS NOT NULL OR option_id IS NOT NULL) AND returned_date IS NULL"]
  named_scope :to_remind,     :conditions => ["(item_id IS NOT NULL OR option_id IS NOT NULL) AND returned_date IS NULL AND end_date < CURDATE()"]
  named_scope :deadline_soon, :conditions => ["(item_id IS NOT NULL OR option_id IS NOT NULL) AND returned_date IS NULL AND end_date = ADDDATE(CURDATE(), 1)"]

################################################## 

  def is_late?(current_date = Date.today)
    returned_date.nil? and end_date < current_date
  end
  
  def document
    contract
  end

##################################################

  private
      
  def inventory_pool_open
    errors.add_to_base(_("This inventory pool is closed on the proposed end date")) if end_date and not contract.inventory_pool.is_open_on?(end_date)
  end
    
end

