# A ContractLine is a line in a #Contract (based on an #Order) and
# differentiated into its subclasses #ItemLine and #OptionLine.
#
# Each ContractLine refers to some borrowable thing - which can either
# be an #Option or a #Model. In the case of a #Model, it does not
# have specific instances of that #Model in the begining and only gets
# them once the manager chooses a specific #Item of the #Model that the
# customer wants.
#
class ContractLine < ActiveRecord::Base
  include Availability::ContractLine

  belongs_to :purpose
  belongs_to :contract, inverse_of: :contract_lines
  alias :document :contract
  has_one :user, :through => :contract
  has_many :groups, :through => :user
  belongs_to :returned_to_user, :class_name => "User"

  delegate :inventory_pool, :to => :contract
  
  validates_presence_of :contract
  # TODO validates_presence_of :purpose, if: Proc.new { |record| record.status != :unsubmitted }

####################################################

  # TODO default_scope :joins ??
  #Rails3.1# default_scope -> {order("start_date ASC, end_date ASC, contract_lines.created_at ASC")}
  
  # these are the things we need to_take_back, to_hand_over, to_approve, ...
  # NOTE using table alias to prevent "Not unique table/alias" Mysql error

  scope :with_contract_status, -> (status) { joins(:contract).where(:contracts => {:status => status}, :returned_date => nil).readonly(false) }
  scope :to_approve, -> { with_contract_status(:submitted) }
  scope :to_hand_over, -> { with_contract_status(:approved) }
  scope :to_take_back, -> { with_contract_status(:signed) }
  scope :handed_over_or_assigned_but_not_returned, -> { where(returned_date: nil).where("NOT (end_date < ? AND item_id IS NULL)", Date.today)}
  
  # TODO 1209** refactor to InventoryPool has_many :contract_lines_by_user(user) ??
  # NOTE InventoryPool#contract_lines.by_user(user)
  scope :by_user, lambda { |user| joins(:contract).where(:contracts => {:user_id => user}) }
  #temp# scope :by_user, lambda { |user| joins(:contract).where(["contracts.user_id = ?", user]) }
  scope :by_inventory_pool, lambda { |inventory_pool|
                              joins(:contract).where(:contracts => {:inventory_pool_id => inventory_pool})
                            }

  def self.filter(params, inventory_pool = nil)
    contract_lines = if inventory_pool
                       inventory_pool.contract_lines
                     else
                       all
                     end
    contract_lines = contract_lines.where(contract_id: params[:contract_ids]) if params[:contract_ids]
    contract_lines = contract_lines.where(id: params[:ids]) if params[:ids]
    contract_lines
  end

##################################################### 

  def is_late?(current_date = Date.today)
    returned_date.nil? and end_date < current_date
  end
  
  def is_reserved?
    start_date > Date.today and item
  end

###############################################

  before_validation :set_defaults, :on => :create
  validate :date_sequence
  validates_numericality_of :quantity, :greater_than => 0, :only_integer => true

  # compares two objects in order to sort them
  def <=>(other)
    # TODO prevent name with leading and trailing whitespaces directly on model and option save
    [self.start_date, self.model.name.strip] <=> [other.start_date, other.model.name.strip]
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


