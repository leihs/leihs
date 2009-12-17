class ContractLine < DocumentLine
  
  belongs_to :contract
  belongs_to :location
  
  delegate :inventory_pool, :to => :contract
  
  validates_presence_of :contract
  
####################################################

  named_scope :to_hand_over,  :include => :contract, :conditions => ["contracts.status_const = ?", Contract::UNSIGNED]
  named_scope :to_take_back,  :include => :contract, :conditions => ["contracts.status_const = ? AND returned_date IS NULL", Contract::SIGNED]
  named_scope :to_remind,     :include => :contract, :conditions => ["contracts.status_const = ? AND returned_date IS NULL AND end_date < CURDATE()", Contract::SIGNED]
  named_scope :deadline_soon, :include => :contract, :conditions => ["contracts.status_const = ? AND returned_date IS NULL AND end_date = ADDDATE(CURDATE(), 1)", Contract::SIGNED]

  # TODO 1209** refactor to InventoryPool has_many :contract_lines_by_user(user) ??
  # NOTE InventoryPool#contract_lines.by_user(user)
  named_scope :by_user, lambda { |user| { :conditions => ["contracts.user_id = ?", user] } }
  #temp# named_scope :by_user, lambda { |user| { :joins => :contract, :conditions => ["contracts.user_id = ?", user] } }

##################################################### 

  def is_late?(current_date = Date.today)
    returned_date.nil? and end_date < current_date
  end
  
  def document
    contract
  end

end

