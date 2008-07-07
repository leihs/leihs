class LineGroup < ActiveRecord::Base

  has_many :order_lines
  has_many :contract_lines
  
  belongs_to :package

end
