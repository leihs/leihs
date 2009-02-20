class Contract < Document

  belongs_to :inventory_pool # common for sibling classes
  belongs_to :user
  
# TODO 1602**  
  has_many :contract_lines, :dependent => :destroy, :order => 'start_date ASC, created_at ASC'
  has_many :item_lines, :dependent => :destroy, :order => 'start_date ASC, created_at ASC'
  has_many :option_lines, :dependent => :destroy, :order => 'start_date ASC, created_at ASC'

  has_many :models, :through => :item_lines, :uniq => true
  has_many :items, :through => :item_lines, :uniq => false
  has_many :options, :through => :option_lines, :uniq => true

  # TODO union of results :or_default => true
  acts_as_ferret :fields => [ :user_login, :lines_model_names ], :store_class_name => true, :remote => true


  NEW = 1
  SIGNED = 2
  CLOSED = 3

  STATUS = {_("New") => NEW, _("Signed") => SIGNED, _("Closed") => CLOSED }

  def status_string
    n = STATUS.index(status_const)
    n.nil? ? status_const : n
  end

  # alias
  def lines
    contract_lines
  end


#########################################################################

  named_scope :new_contracts, :conditions => {:status_const => Contract::NEW}
  named_scope :signed_contracts, :conditions => {:status_const => Contract::SIGNED}
  named_scope :closed_contracts, :conditions => {:status_const => Contract::CLOSED}

#########################################################################

  def sign(contract_lines = nil)
    update_attribute :status_const, Contract::SIGNED 

    if contract_lines and contract_lines.any? { |cl| cl.item }

      # Forces handover date to be today.
      contract_lines.each {|cl| cl.update_attribute :start_date, Date.today if cl.start_date != Date.today }
      
      lines_for_new_contract = self.contract_lines - contract_lines
      if lines_for_new_contract
        new_contract = user.get_current_contract(self.inventory_pool)
  
        lines_for_new_contract.each do |cl|
          cl.update_attribute :contract, new_contract
        end
      end
      
    end
  end

  def close
    update_attribute :status_const, Contract::CLOSED
  end



end
