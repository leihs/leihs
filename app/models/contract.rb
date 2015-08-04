class Contract < ActiveRecord::Base
  include LineModules::GroupedAndMergedLines
  include DefaultPagination
  audited

  has_many :reservations, -> { order('reservations.start_date ASC, reservations.end_date ASC, reservations.created_at ASC') }, dependent: :destroy #Rails3.1# TODO Reservation#default_scope
  has_many :item_lines, -> { order('reservations.start_date ASC, reservations.end_date ASC, reservations.created_at ASC') }, dependent: :destroy
  has_many :option_lines, -> { order('reservations.start_date ASC, reservations.end_date ASC, reservations.created_at ASC') }, dependent: :destroy
  has_many :models, -> { order('reservations.start_date ASC, reservations.end_date ASC, models.product ASC').uniq }, through: :item_lines
  has_many :items, through: :item_lines
  has_many :options, -> { uniq }, through: :option_lines

  #########################################################################

  validate do
    if reservations.empty?
      errors.add(:base, _("This contract is not signable because it doesn't have any contract reservations."))
    else
      errors.add(:base, _('The assigned contract reservations have to be marked either as signed or as closed')) if reservations.any? { |line| not [:signed, :closed].include?(line.status) }
      errors.add(:base, _('The start_date is not unique')) if reservations.map(&:start_date).uniq.size != 1
      errors.add(:base, _('This contract is not signable because none of the reservations have a purpose.')) unless reservations.any? &:purpose
      errors.add(:base, _('This contract is not signable because some reservations are not assigned.')) unless reservations.all? &:item
      errors.add(:base, _('Start Date must be before End Date')) if reservations.any? {|l| l.end_date < Date.today }
    end
  end
  #########################################################################

  # compares two objects in order to sort them
  def <=>(other)
    self.created_at <=> other.created_at
  end

  def to_s
    "#{id}"
  end

  TIMEOUT_MINUTES = 30

end
