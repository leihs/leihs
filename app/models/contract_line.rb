class ContractLine < DocumentLine
  
  belongs_to :item
  belongs_to :contract

  
  validate :item_model_matching
  

  # custom valid? method
  # returns boolean
  def complete?
    !self.item.nil? and self.valid? and self.available?
  end

  
  private
  
  # validator
  def item_model_matching
    errors.add_to_base(_("The item doesn't match with the reserved model")) if !item.nil? and item.model != model
  end
  
  
end
