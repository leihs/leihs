class Contract < ActiveRecord::Base
  include LineModules::GroupedAndMergedLines
  include DefaultPagination

  has_many :contract_lines, -> { order('contract_lines.start_date ASC, contract_lines.end_date ASC, contract_lines.created_at ASC') }, :dependent => :destroy #Rails3.1# TODO ContractLin#default_scope
  has_many :item_lines, -> { order('contract_lines.start_date ASC, contract_lines.end_date ASC, contract_lines.created_at ASC') }, :dependent => :destroy
  has_many :option_lines, -> { order('contract_lines.start_date ASC, contract_lines.end_date ASC, contract_lines.created_at ASC') }, :dependent => :destroy
  has_many :models, -> { order('contract_lines.start_date ASC, contract_lines.end_date ASC, models.product ASC').uniq }, :through => :item_lines
  has_many :items, :through => :item_lines
  has_many :options, -> { uniq }, :through => :option_lines

  #########################################################################

  validate do
    if contract_lines.empty?
      errors.add(:base, _("This contract is not signable because it doesn't have any contract lines."))
    else
      errors.add(:base, _("The assigned contract lines have to be marked either as signed or as closed")) if contract_lines.any? { |line| not [:signed, :closed].include?(line.status) }
      errors.add(:base, _("The start_date is not unique")) if contract_lines.map(&:start_date).uniq.size != 1
      errors.add(:base, _("This contract is not signable because none of the lines have a purpose.")) unless contract_lines.any? &:purpose
      errors.add(:base, _("This contract is not signable because some lines are not assigned.")) unless contract_lines.all? &:item
      errors.add(:base, _("Start Date must be before End Date")) if contract_lines.any? {|l| l.end_date < Date.today }
    end
  end
  #########################################################################

  # alias
  def lines(reload = false)
    contract_lines(reload)
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.created_at <=> other.created_at
  end

  def to_s
    "#{id}"
  end

  TIMEOUT_MINUTES = 30

end
