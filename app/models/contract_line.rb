class ContractLine < ActiveRecord::Base
  belongs_to :item
  belongs_to :contract
  belongs_to :order_line
  
  
  # TODO validation: item.model == order_line.model
  
  def <=>(other)
    self.start_date <=> other.start_date
  end
  
end
