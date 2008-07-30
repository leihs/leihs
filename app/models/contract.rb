class Contract < Document

  belongs_to :inventory_pool # common for sibling classes
  belongs_to :user
  has_many :contract_lines, :dependent => :destroy
  has_many :models, :through => :contract_lines #OPTIMIZE , :uniq => true
  has_many :line_groups, :through => :contract_lines, :uniq => true
  # TODO remove Printout: has_and_belongs_to_many :printouts  #, :dependent => :destroy

  acts_as_ferret :fields => [ :user_login, :lines_model_names ],
                 :store_class_name => true
                 # TODO union of results :or_default => true


  NEW = 1
  SIGNED = 2
  CLOSED = 3
  
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

      # double check
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

#  def to_pdf
## TODO remove Printout    printout = Printout.create
#    
#    ### Start PDF
#      fpdf = FPDF.new
#      fpdf.AddPage
#  
#      fpdf.SetFont('Arial', 'B', 16)
#      fpdf.Cell(40, 10, "Contract: #{id}") # "-#{printout.id}"
#      fpdf.Ln
#  
#      fpdf.SetFont('Arial', '', 10)
#      lines.each do |l|
#        fpdf.Write(5, "#{l.quantity} #{l.model.name} #{l.start_date} #{l.end_date} #{l.returned_date}")
#        fpdf.Ln(5)
#      end
#    ### End PDF
#
## TODO remove Printout
##    printout.pdf = fpdf.Output
##    printout.save
##    printouts << printout
#    fpdf.Output
#  end


end
