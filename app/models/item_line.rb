# An ItemLine is a line in a #Contract and as such derived from the
# more general ContractLine. It only contains #Item s but NOT
# #Option s.
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
  
  belongs_to :item, inverse_of: :item_lines
  belongs_to :model, inverse_of: :contract_lines

  validates_numericality_of :quantity, :equal_to => 1
  validate :validate_item
  validates_presence_of :model_id

# TODO 1301  default_scope -> {includes(:model).order("models.product")}

  # OPTMIZE 0209** overriding the item getter in order to get a retired item as well if is the case
  def item
    Item.unscoped { Item.where(:id => item_id).first } if item_id   
  end  

  def to_s
    "#{item} - #{end_date.strftime('%d.%m.%Y')}"
  end

  before_save do
    # keep the unsubmitted contract computed for the availability
    contract.touch if contract.status == :unsubmitted and not contract.user.timeout?
  end

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
    contract.status == :signed and super
  end

##################################################

  private

  # validator
  def validate_item
    if item_id and contract.status == :approved
      # model matching
      errors.add(:base, _("The item doesn't match with the reserved model")) unless item.model_id == model_id

      if item_already_handed_over_or_assigned_to_the_same_contract?
        # check if already assigned to the same contract
        errors.add(:base, _("%s is already assigned to this contract") % item.inventory_code)

      elsif item_already_handed_over_or_assigned_to_a_different_contract?
        # check if available
        errors.add(:base, _("%s is already assigned to a different contract") % item.inventory_code) 
      end

      # inventory_pool matching
      errors.add(:base, _("The item doesn't belong to the inventory pool related to this contract")) unless item.inventory_pool_id == contract.inventory_pool_id 

      # package check 
      errors.add(:base, _("The item belongs to a package")) if item.parent_id
    end
  end

  def item_already_handed_over_or_assigned_to_a_different_contract?
    item.contract_lines.handed_over_or_assigned_but_not_returned.where(["id != ? and contract_id != ?", id, contract.id]).exists?
  end

  def item_already_handed_over_or_assigned_to_the_same_contract?
    item.contract_lines.handed_over_or_assigned_but_not_returned.where(["id != ? and contract_id = ?", id, contract.id]).exists?
  end

end

