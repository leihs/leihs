class ItemLine < ContractLine
  
  belongs_to :item
  belongs_to :model

  validate :validate_item

  def to_s
    "#{item} - #{end_date.strftime('%d.%m.%Y')}"
  end

# TODO 2602** important: check this method!!!
#  before_save { |record| 
#    unless record.returned_date
#      #TODO 27 Commented for import
#      # But what happens if an inventory manager sees on the next day that he put in the wrong number and wants to correct it?
#      # record.item = nil if record.start_date != Date.today
#      record.start_date = Date.today unless record.item.nil?
#    end
#  }

##################################################

  # custom valid? method
  def complete?
    !self.item.nil? and super
  end

  # TODO 04** merge in complete? 
  def complete_tooltip
    r = super
    r += _("item not assigned. ") unless !self.item.nil?
    return r
  end

##################################################

  def is_late?(current_date = Date.today)
    item and super
  end

# TODO 1602**
#  def max_end_date
#    a = model.available_periods_for_document_line(self)
#    d = a.detect {|x| x.start_date >= end_date and x.quantity < 1 }
#    # TODO 1202** make sure we can use end_date of last available period
#    (d ? d.start_date - (1 + model.maintenance_period).days : nil)
#  end

##################################################

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
