# An ItemLine is a line in a #Contract and as such derived from the
# more general ContractLine. It only contains #Item s but NOT
# #Option s. The latter ones are part of #OrderLine s.
#
# An ItemLine at first only contains a #Model and a desired quantity
# of that #Model. It's only after the #InventoryPool manager has
# picked specific instances of that #Model - which are called "#Items"
# in _leihs_ - that the ItemLines get to contain #Items.
#
# See also the page "Flow" inside the models.graffle document for a
# description of the various steps the lending process goes through.
#
class ItemLine < ContractLine
  
  belongs_to :item
  belongs_to :model

  # TODO validate quantity always 1
  validate :validate_item

# TODO 1301  default_scope includes(:model).order("models.name")

  # OPTMIZE 0209** overriding the item getter in order to get a retired item as well if is the case
  def item
    Item.unscoped { Item.where(:id => item_id).first } if item_id   
  end  

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
    # an ItemLine can only be late if the Item has been
    # handed out. And an Item can only be handed out, if
    # the contract has been signed. Thus:
    contract.status_const == Contract::SIGNED and super
  end

# TODO 1602**
#  def max_end_date
#    a = model.available_periods_for_document_line(self)
#    d = a.detect {|x| x.start_date >= end_date and x.quantity < 1 }
#    # TODO 1202** make sure we can use end_date of last available period
#    (d ? d.start_date - (1 + model.maintenance_period).days : nil)
#  end

##################################################

  def as_json(options = {})
    options ||= {} # NOTE workaround, because options is nil, is this a BUG ??
    json = super(options)

    if (with = options[:with]) and with[:availability]
      if (customer_user = with[:availability][:user])
        json['total_borrowable'] = model.total_borrowable_items_for_user(customer_user)
        json['availability_for_user'] = model.availability_periods_for_user(customer_user)
      end
      
      if (current_inventory_pool = with[:availability][:inventory_pool])
        borrowable_items = model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
        json['total_rentable'] = borrowable_items.count
        json['total_rentable_in_stock'] = borrowable_items.in_stock.count
      end
    end

    json
  end

##################################################

  private
    
  # validator
  def validate_item
    if item and contract.status_const == Contract::UNSIGNED
      # model matching
      errors.add(:base, _("The item doesn't match with the reserved model")) unless item.model == model
  
      # check if available
      errors.add(:base, _("The item is already handed over or assigned to a different contract line")) if item_already_handed_over_or_assigned?
   
      # inventory_pool matching
      errors.add(:base, _("The item doesn't belong to the inventory pool related to this contract")) unless item.inventory_pool == contract.inventory_pool 

      # package check 
      errors.add(:base, _("The item belongs to a package")) if item.parent
    end
  end
  
  def item_already_handed_over_or_assigned?
    item.contract_lines.handed_over_or_assigned_but_not_returned(Date.today).where(["id != ?", id]).count > 0
  end
  
end

