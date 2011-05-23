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
  belongs_to :location
  
  delegate :inventory_pool, :to => :contract
  
  validates_presence_of :contract
  
####################################################

  # NOTE using table alias to prevent "Not unique table/alias" Mysql error
  # TODO default_scope :joins ??
  # these are the things we need to_take_back, to_hand_over, ...
  scope :to_hand_over,  :joins => "INNER JOIN contracts AS my_contract ON my_contract.id = contract_lines.contract_id",
                              :conditions => ["my_contract.status_const = ?", Contract::UNSIGNED]
  scope :to_take_back,  :joins => "INNER JOIN contracts AS my_contract ON my_contract.id = contract_lines.contract_id",
                              :conditions => ["my_contract.status_const = ? AND contract_lines.returned_date IS NULL", Contract::SIGNED]
  scope :handed_over_or_assigned_but_not_returned,
                              lambda { |date|
                                       { :conditions => ["returned_date IS NULL AND NOT (end_date < ? AND item_id IS NULL)", date] }
                                     }
  scope :to_remind,  :joins => "INNER JOIN contracts AS my_contract ON my_contract.id = contract_lines.contract_id",
                           :conditions => ["my_contract.status_const = ? AND contract_lines.returned_date IS NULL AND contract_lines.end_date < CURDATE()", Contract::SIGNED]
  scope :deadline_soon,  :joins => "INNER JOIN contracts AS my_contract ON my_contract.id = contract_lines.contract_id",
                               :conditions => ["my_contract.status_const = ? AND contract_lines.returned_date IS NULL AND contract_lines.end_date = ADDDATE(CURDATE(), 1)", Contract::SIGNED]
  
  # TODO 1209** refactor to InventoryPool has_many :contract_lines_by_user(user) ??
  # NOTE InventoryPool#contract_lines.by_user(user)
  scope :by_user, lambda { |user| { :conditions => ["contracts.user_id = ?", user] } }
  #temp# scope :by_user, lambda { |user| { :joins => :contract, :conditions => ["contracts.user_id = ?", user] } }
  scope :by_inventory_pool, lambda { |inventory_pool| {:joins => :contract,
                                                             :conditions => {:contracts => {:inventory_pool_id => inventory_pool}} } }

##################################################### 

  def is_late?(current_date = Date.today)
    returned_date.nil? and end_date < current_date
  end
  
  def is_reserved?
    start_date > Date.today && item
  end
  def document
    contract
  end

end


