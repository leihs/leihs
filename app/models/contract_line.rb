# A ContractLine is differentiated into its subclasses #ItemLine and #OptionLine.
#
# Each ContractLine refers to some borrowable thing - which can either
# be an #Option or a #Model. In the case of a #Model, it does not
# have specific instances of that #Model in the begining and only gets
# them once the manager chooses a specific #Item of the #Model that the
# customer wants.
#
class ContractLine < ActiveRecord::Base
  include Availability::ContractLine
  include Delegation::ContractLine

  belongs_to :inventory_pool, inverse_of: :contract_lines
  belongs_to :user, inverse_of: :contract_lines
  belongs_to :purpose
  belongs_to :contract, inverse_of: :contract_lines
  belongs_to :handed_over_by_user, :class_name => "User"
  belongs_to :returned_to_user, :class_name => "User"

  has_many :groups, :through => :user
  has_many :histories, -> { order(:created_at) }, as: :target, dependent: :delete_all

  def contract_id
    read_attribute(:contract_id) || "#{status}_#{user_id}_#{inventory_pool_id}"
  end

  def contract_with_container
    contract_without_container || ContractLinesBundle.find_by(status: status, user_id: user_id, inventory_pool_id: inventory_pool_id)
  end
  alias_method_chain :contract, :container

  #########################################################################

  STATUSES = [:unsubmitted, :submitted, :rejected, :approved, :signed, :closed]

  def status
    read_attribute(:status).to_sym
  end

  STATUSES.each do |status|
    scope status, -> {where(status: status)}
  end

  #########################################################################

  default_scope -> { order(:start_date, :end_date, :created_at) }

  scope :handed_over_or_assigned_but_not_returned, -> { where(returned_date: nil).where("NOT (end_date < ? AND item_id IS NULL)", Date.today)}

  def self.filter(params, inventory_pool)
    contract_lines = inventory_pool.contract_lines

    if params[:contract_ids]
      conditions = params[:contract_ids].map do |p|
        if p.include?('_')
          "(status = '%s' AND user_id = %d)" % p.split('_')[0,2]
        else
          "contract_id = %d" % p
        end
      end.join(' OR ')
      contract_lines = contract_lines.where(conditions)
    end

    contract_lines = contract_lines.where(id: params[:ids]) if params[:ids]
    contract_lines
  end

#####################################################

  before_validation :set_defaults, on: :create
  validates_numericality_of :quantity, greater_than: 0, only_integer: true
  validates_presence_of :user, :inventory_pool, :status
  validates_presence_of :contract, if: Proc.new {|r| [:signed, :closed].include?(r.status) }
  # TODO validates_presence_of :purpose, if: Proc.new { |record| record.status != :unsubmitted }
  validate :date_sequence
  validate do
    errors.add(:base, _("No access")) unless user.access_right_for(inventory_pool)
    if user.is_delegation
      errors.add(:base, _("Delegated user is not member of the contract's delegation or is empty")) unless user.delegated_users.include?(delegated_user)
    else
      errors.add(:base, _("Delegated user must be empty for contract's normal user")) if delegated_user
    end
  end

  before_save do
    if returned_date and returned_date_changed?
      self.status = :closed
    end
  end
###############################################

  # compares two objects in order to sort them
  def <=>(other)
    # TODO prevent name with leading and trailing whitespaces directly on model and option save
    [self.start_date, self.model.name.strip] <=> [other.start_date, other.model.name.strip]
  end

  def is_late?(current_date = Date.today)
    returned_date.nil? and end_date < current_date
  end

  def is_reserved?
    start_date > Date.today and item
  end

###############################################

# TODO 03** merge here available_tooltip and complete_tooltip
  def tooltip
    r = ""
    r += self.available_tooltip
    r += "<br/>"
    r += self.complete_tooltip
    # TODO 03** include errors?
    # r += self.errors.full_messages.uniq
    return r
  end

  def visits_on_open_date?
    inventory_pool.is_open_on?(start_date) and inventory_pool.is_open_on?(end_date)
  end

  # custom valid? method
  def complete?
    self.valid? and self.available?
  end

  # TODO 04** merge in complete?
  def complete_tooltip
    r = ""
    r += _("not valid. ") unless self.valid? # TODO 04** self.errors.full_messages.uniq
    r += _("not available. ") unless self.available?
    return r
  end

  # TODO 04** merge in available?
  def available_tooltip
    r = ""
    r += _("quantity not available. ") unless available?
    r += _("inventory pool is closed on start_date. ") unless inventory_pool.is_open_on?(start_date)
    r += _("inventory pool is closed on end_date. ") unless inventory_pool.is_open_on?(end_date)
    return r
  end

  ###############################################

  def price
    (item.price || 0) * quantity
  end

  def price_or_max_price
    if item
      (item.price || 0) * quantity
    else
      (model.borrowable_items.where(inventory_pool_id: inventory_pool).map(&:price).compact.max || 0) * quantity
    end
  end

  # TODO dry with ContractLinesBundle
  def target_user
    if user.is_delegation and delegated_user
      delegated_user
    else
      user
    end
  end

  ############################################

  def approvable?
    if status == :approved
      errors.add(:base, _("This order has already been approved."))
      false
    else
      errors.add(:base, _("This user is suspended.")) if user.suspended?(inventory_pool)
      errors.add(:base, _("The delegated user %s is suspended.") % delegated_user) if delegated_user.try :suspended?, inventory_pool
      errors.add(:base, _("This order is not approvable because the inventory pool is closed on either the start or enddate.")) unless visits_on_open_date?
      errors.add(:base, _("This order is not approvable because some reserved models are not available.")) unless available?
      errors.add(:base, _("Please provide a purpose...")) if purpose.to_s.blank?
      errors.empty?
    end
  end

  def update_time_line(start_date, end_date, user_id)
    ContractLine.transaction do
      start_date ||= self.start_date
      end_date ||= self.end_date
      original_start_date = self.start_date
      original_end_date = self.end_date
      self.start_date = start_date
      self.end_date = [start_date, end_date].max
      if save
        change = _("Changed dates for %{model} from %{from} to %{to}") % {model: model.name, from: "#{original_start_date} - #{original_end_date}", to: "#{start_date} - #{end_date}"}
        log_change(change, user_id)
      end
      if User.find(user_id).access_right_for(inventory_pool).role == :group_manager and not line.available?
        raise _("Not available")
      end
    end
  end

  ############################################

  def log_change(text, user_id)
    user_id = user_id.id if user_id.is_a? User
    histories.create(text: text, user_id: user_id, type_const: History::CHANGE) unless (user and user_id == user.id)
  end

  private

  def set_defaults
    self.start_date ||= Date.today
    self.end_date ||= Date.today
  end

  def date_sequence
    # OPTIMIZE strange behavior: in some cases, this error raises when shouldn't
    errors.add(:base, _("Start Date must be before End Date")) if end_date < start_date
    #TODO: Think about this a little bit more.... errors.add(:base, _("Start Date cannot be a past date")) if start_date < Date.today
  end

end


