class Contract < Document

  belongs_to :user
  has_many :contract_lines, :dependent => :destroy
  has_and_belongs_to_many :printouts  # TODO , :dependent => :destroy

  NEW = 1
  SIGNED = 2    

  # alias
  def lines
    contract_lines
  end


#########################################################################

  def self.new_contracts
    find(:all, :conditions => {:status_const => Contract::NEW})
  end

  def self.signed_contracts
    find(:all, :conditions => {:status_const => Contract::SIGNED})
  end

#########################################################################


  def sign
    if contract_lines.any? { |cl| !cl.item.nil? }
      self.status_const = Contract::SIGNED 
      save
    
      if contract_lines.any? { |cl| cl.item.nil? }
        new_contract = user.get_current_contract
        contract_lines.each do |cl|
          cl.contract = new_contract if cl.item.nil?
          cl.save
        end
      end

      end
  end


  # TODO implement
  def to_pdf    
  end




end
