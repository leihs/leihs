# == Schema Information
#
# Table name: contract_lines
#
#  id            :integer(4)      not null, primary key
#  contract_id   :integer(4)
#  item_id       :integer(4)
#  model_id      :integer(4)
#  quantity      :integer(4)      default(1)
#  start_date    :date
#  end_date      :date
#  returned_date :date
#  created_at    :datetime
#  updated_at    :datetime
#  option_id     :integer(4)
#  type          :string(255)     default("ItemLine"), not null
#

# an OptionLine is a line in a #Contract that can only contain
# #Option's and NOT #Item's.
#
class OptionLine < ContractLine

  belongs_to :option

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
    self.errors.full_messages
  end


  def is_late?(current_date = Date.today)
    option and super
  end


########################################################
# aliases

  belongs_to :item, :class_name => "Option", :foreign_key => :option_id
  belongs_to :model, :class_name => "Option", :foreign_key => :option_id

##################################################

  private
    
  # inventory_pool matching validator
  def validate_inventory_pool
    errors.add(:base, _("The option doesn't belong to the inventory pool related to this contract")) unless option.inventory_pool == contract.inventory_pool 
  end


end

