# A Contract is a #Document containing #ContractLine s. It gets
# created from an #Order, once the #Order is acknowledged by an
# #InventoryPool manager.
#
# The page "Flow" inside the models.graffle document shows the
# various steps though which a #Document goes from #Order to
# finally closed Contract.
#
class Contract < Document

  belongs_to :inventory_pool # common for sibling classes
  belongs_to :user
  
  has_many :contract_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC'
  has_many :item_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC'
  has_many :option_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC'
  has_many :models, :through => :item_lines, :uniq => true, :order => 'contract_lines.start_date ASC, contract_lines.end_date ASC, models.name ASC'
  has_many :items, :through => :item_lines, :uniq => false
  has_many :options, :through => :option_lines, :uniq => true

  define_index do
    indexes :id
    indexes :note
    indexes user(:login), :as => :user_login
    indexes user(:badge_id), :as => :user_badge_id
    indexes models(:name), :as => :model_names
    indexes items(:inventory_code), :as => :items_inventory_code
    
    has :inventory_pool_id, :user_id, :status_const
    
    set_property :delta => true
  end

  # TODO validates_uniqueness [user_id, inventory_pool_id, status_const] if status_consts == Contract::UNSIGNED

  UNSIGNED = 1
  SIGNED = 2
  CLOSED = 3

  STATUS = {_("Unsigned") => UNSIGNED, _("Signed") => SIGNED, _("Closed") => CLOSED }

  def status_string
    n = STATUS.index(status_const)
    n.nil? ? status_const : n
  end

  # alias
  def lines
    contract_lines
  end

#########################################################################

  named_scope :unsigned, :conditions => {:status_const => Contract::UNSIGNED}
  named_scope :signed, :conditions => {:status_const => Contract::SIGNED}
  named_scope :closed, :conditions => {:status_const => Contract::CLOSED}
  
  # OPTIMIZE use INNER JOIN (:joins => :contract_lines) -OR- union :unsigned + :signed (with lines) 
  named_scope :pending, :select => "DISTINCT contracts.*",
                        :joins => "LEFT JOIN contract_lines ON contract_lines.contract_id = contracts.id",
                        :conditions => ["contracts.status_const = :signed
                                         OR (contracts.status_const = :unsigned AND
                                             contract_lines.contract_id IS NOT NULL)",
                                        {:signed => Contract::SIGNED,
                                         :unsigned => Contract::UNSIGNED }]

  named_scope :by_inventory_pool,  lambda { |inventory_pool| { :conditions => { :inventory_pool_id => inventory_pool } } }

# 0501 rename /sphinx_/ and remove relative named_scope
  sphinx_scope(:sphinx_unsigned) { { :with => {:status_const => Contract::UNSIGNED} } }
  sphinx_scope(:sphinx_signed) { { :with => {:status_const => Contract::SIGNED} } }
  sphinx_scope(:sphinx_closed) { { :with => {:status_const => Contract::CLOSED} } }

#########################################################################

  # TODO: we don't have a single place where we call sign without a current_user, except in a new test
  #       -> eliminate the default value and the assignement current_user ||=
  def sign(contract_lines = nil, current_user = nil)
    current_user ||= self.user
    
    transaction do
      update_attributes({:status_const => Contract::SIGNED, :created_at => Time.now}) 
  
      if contract_lines and contract_lines.any? { |cl| cl.item }
  
        # Forces handover date to be today.
        contract_lines.each {|cl| cl.update_attributes(:start_date => Date.today) if cl.start_date != Date.today }
        
        log_history(_("Contract %d has been signed by %s") % [self.id, self.user.name], current_user.id)
        
        lines_for_new_contract = self.contract_lines - contract_lines
        if lines_for_new_contract
          new_contract = user.get_current_contract(self.inventory_pool)
    
          lines_for_new_contract.each do |cl|
            cl.update_attributes(:contract => new_contract)
          end
        end        
      end
    end
  end

  def close
    update_attributes(:status_const => Contract::CLOSED)
  end

end
