class LineGroup < ActiveRecord::Base

  has_many :order_lines
  has_many :contract_lines
  
  belongs_to :model_group

  validate :package_dependencies

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

  private
  
  # make sure every related line is related to the same inventory pool and has the same time period
  def package_dependencies
    if model_group.is_a?(Package)
      errors.add_to_base(_("The lines are not related to the same time period")) unless lines.all? {|l| l.start_date == lines.first.start_date and l.end_date == lines.first.end_date }
      if contract_lines.empty? 
        errors.add_to_base(_("The lines are not related to the same inventory pool")) unless lines.all? {|l| l.inventory_pool == l.order.inventory_pool }
      end
    end
  end
  

end
