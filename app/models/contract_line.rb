class ContractLine < ActiveRecord::Base
  belongs_to :item
  belongs_to :contract
  belongs_to :model
  
  validate :item_model_matching
  
  # compares two objects in order to sort the
  def <=>(other)
    self.start_date <=> other.start_date
  end

  # custom valid? method
  # returns boolean
  def complete?
    !self.item.nil? and self.valid? and self.available?
  end

  # TODO method copied from order_line
  def available?
    model.maximum_available_in_period(start_date, end_date, id) >= quantity
  end
  
  
  private
  
  # validator
  def item_model_matching
    errors.add_to_base(_("The item doesn't match with the reserved model")) if !item.nil? and item.model != model
  end
  
  
end
