class LineGroup < ActiveRecord::Base

  has_many :order_lines
  has_many :contract_lines
  
  belongs_to :model_group

  # TODO validation: make sure every related line is related to the same inventory pool

  # TODO dependency for packages (Template of type Package)
end
