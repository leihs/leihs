class Contract < ActiveRecord::Base

  belongs_to :user
  has_many :contract_lines, :dependent => :destroy

  NEW = 1
  SIGNED = 2    

  def sign

      contract_lines.each do |cl|
        cl.destroy if cl.item.nil?
      end

      self.status_const = Contract::SIGNED 
      save

  end


  # TODO pdf
  def to_pdf
    
  end

end
