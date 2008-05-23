class Contract < Document

  belongs_to :user
  has_many :contract_lines, :dependent => :destroy

  NEW = 1
  SIGNED = 2    

  # alias
  def lines
    contract_lines
  end


#########################################################################

#  def self.new_contracts
#    find(:all, :conditions => {:status_const => Contract::NEW})
#  end

  def self.signed_contracts
    find(:all, :conditions => {:status_const => Contract::SIGNED})
  end

#########################################################################



  def sign
      contract_lines.each do |cl|
        cl.destroy if cl.item.nil?
      end

      self.status_const = Contract::SIGNED 
      save

  end


  # TODO implement
  def to_pdf    
  end




end
