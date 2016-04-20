class Contract < ActiveRecord::Base
  include LineModules::GroupedAndMergedLines
  include DefaultPagination
  audited

  ORDER_BY = lambda do
    order('reservations.start_date ASC, ' \
          'reservations.end_date ASC, ' \
          'reservations.created_at ASC')
  end

  has_many :reservations,
           ORDER_BY,
           dependent: :destroy
  has_many :item_lines,
           ORDER_BY,
           dependent: :destroy
  has_many :option_lines,
           ORDER_BY,
           dependent: :destroy
  has_many :models,
           (lambda do
             order('reservations.start_date ASC, ' \
                   'reservations.end_date ASC, ' \
                   'models.product ASC').uniq
           end),
           through: :item_lines
  has_many :items, through: :item_lines
  has_many :options, -> { uniq }, through: :option_lines

  #########################################################################

  validate do
    if reservations.empty?
      errors.add(:base,
                 _('This contract is not signable because ' \
                   "it doesn't have any contract reservations."))
    else
      if reservations.any? { |line| not [:signed, :closed].include?(line.status) }
        errors.add(:base, _('The assigned contract reservations have to be ' \
                            'marked either as signed or as closed'))
      end
      if reservations.map(&:start_date).uniq.size != 1
        errors.add(:base, _('The start_date is not unique'))
      end
      unless reservations.any? &:purpose
        errors.add(:base, _('This contract is not signable because ' \
                            'none of the reservations have a purpose.'))
      end
      unless reservations.all? &:item
        errors.add(:base, _('This contract is not signable because ' \
                            'some reservations are not assigned.'))
      end
      if reservations.any? { |l| l.end_date < Time.zone.today }
        errors.add(:base, _('Start Date must be before End Date'))
      end
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

end
