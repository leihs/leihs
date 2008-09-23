class ContractLine < DocumentLine
  
  belongs_to :item
  belongs_to :contract
  belongs_to :model # common for sibling classes
  
  delegate :inventory_pool, :to => :contract
  
  validate :validate_item

  # custom valid? method
  # returns boolean
  def complete?
    !self.item.nil? and self.valid? and self.available?
  end

##################################################

  before_save { |record| 
    unless record.returned_date
      record.item = nil if record.start_date != Date.today
      record.start_date = Date.today unless record.item.nil?
    end
  }

##################################################

  named_scope :to_take_back, :conditions => ["item_id IS NOT NULL AND returned_date IS NULL"]
  named_scope :to_remind,    :conditions => ["item_id IS NOT NULL AND returned_date IS NULL AND end_date < CURDATE()"]

##################################################
  
  def order_to_exclude
    0
  end
  
  def contract_to_exclude
    id
  end  

  def is_late?(current_date = Date.today)
    item and returned_date.nil? and end_date < current_date
  end
  
  private
    
  # validator
  def validate_item
    if item
      # model matching
      errors.add_to_base(_("The item doesn't match with the reserved model")) unless item.model == model
  
      # check if available
      errors.add_to_base(_("The item is already handed over")) unless item.in_stock?(id) 
   
      # inventory_pool matching
      errors.add_to_base(_("The item doesn't belong to the inventory pool related to this contract")) unless item.inventory_pool == contract.inventory_pool 
    end
  end
  
   
    
end

