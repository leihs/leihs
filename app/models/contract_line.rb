class ContractLine < ActiveRecord::Base
  belongs_to :item
  belongs_to :contract
  belongs_to :order_line
  
  validate :item_model_matching
  
  # compares two objects in order to sort the
  def <=>(other)
    self.start_date <=> other.start_date
  end

  # custom valid? method
  # returns boolean
  def complete?
    self.valid? and !self.item.nil?
  end

  private
  
  # validator
  def item_model_matching
    errors.add_to_base(_("The item doesn't match with the reserved model")) if !item.nil? and item.model != order_line.model
  end
  
  
end
