# an OptionLine is a line in a #Contract that can only contain
# #Option's and NOT #Item's.
#
class OptionLine < ContractLine

  belongs_to :option, inverse_of: :option_lines

  # aliases, fetching option anyway
  belongs_to :item, :class_name => "Option", :foreign_key => :option_id
  belongs_to :model, :class_name => "Option", :foreign_key => :option_id

  validates_presence_of :option
  validate :validate_inventory_pool

  def to_s
    "#{option} - #{end_date.strftime('%d.%m.%Y')}"
  end

  # custom valid? method
  def complete?
    self.valid?
  end

  def tooltip
    self.errors.full_messages.uniq
  end


  def is_late?(current_date = Date.today)
    option and super
  end

##################################################

  private
    
  # inventory_pool matching validator
  def validate_inventory_pool
    errors.add(:base, _("The option doesn't belong to the inventory pool related to this contract")) unless option.inventory_pool == contract.inventory_pool 
  end


end

