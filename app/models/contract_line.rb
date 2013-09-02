# A ContractLine is a line in a #Contract (based on an #Order) and
# differentiated into its subclasses #ItemLine and #OptionLine.
#
# Each ContractLine refers to some borrowable thing - which can either
# be an #Option or a #Model. In the case of a #Model, it does not
# have specific instances of that #Model in the begining and only gets
# them once the manager chooses a specific #Item of the #Model that the
# customer wants.
#
class ContractLine < DocumentLine
  
  belongs_to :contract
  alias :document :contract
  has_one :user, :through => :contract
  has_many :groups, :through => :user
  belongs_to :returned_to_user, :class_name => "User"

  delegate :inventory_pool, :to => :contract
  
  validates_presence_of :contract
  
####################################################

  # TODO default_scope :joins ??
  #Rails3.1# default_scope order("start_date ASC, end_date ASC, contract_lines.created_at ASC")
  
  # these are the things we need to_take_back, to_hand_over, ...
  # NOTE using table alias to prevent "Not unique table/alias" Mysql error
  scope :to_hand_over, joins(:contract).where(:contracts => {:status_const => Contract::UNSIGNED}, :returned_date => nil).readonly(false)
  scope :to_take_back, joins(:contract).where(:contracts => {:status_const => Contract::SIGNED}, :returned_date => nil).readonly(false)
  scope :handed_over_or_assigned_but_not_returned, where("returned_date IS NULL AND NOT (end_date < CURDATE() AND item_id IS NULL)")
  
  # TODO 1209** refactor to InventoryPool has_many :contract_lines_by_user(user) ??
  # NOTE InventoryPool#contract_lines.by_user(user)
  scope :by_user, lambda { |user| where(:contracts => {:user_id => user}) }
  #temp# scope :by_user, lambda { |user| joins(:contract).where(["contracts.user_id = ?", user]) }
  scope :by_inventory_pool, lambda { |inventory_pool|
                              joins(:contract).where(:contracts => {:inventory_pool_id => inventory_pool})
                            }

##################################################### 

  def is_late?(current_date = Date.today)
    returned_date.nil? and end_date < current_date
  end
  
  def is_reserved?
    start_date > Date.today && item
  end
  
end


