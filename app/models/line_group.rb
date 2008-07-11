class LineGroup < ActiveRecord::Base

  has_many :order_lines
  has_many :contract_lines
  
  belongs_to :model_group

  # TODO dependency for packages (Template of type Package)

  # TODO validation: make sure every related line is related to the same inventory pool
  # TODO validation: make sure every related line has the same time period
  #validate :all_lines_available?  

  # alias
  def lines
    unless contract_lines.empty?
      return contract_lines
    else
      return order_lines
    end
  end

  def available?
    lines.all? {|l| l.available? }
  end


end
