class Visit
  
  attr_accessor :inventory_pool,
                :user,
                :date,
                :contract_lines,
                :quantity
                # TODO action ?

  def initialize(inventory_pool, user, date, contract_line)
    @inventory_pool = inventory_pool
    @user = user
    @date = date
    @contract_lines = [contract_line]
  end

  
  def quantity
    unless @quantity
       @quantity = 0
       @contract_lines.each {|c| @quantity += c.quantity }
    end
    @quantity      
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.date <=> other.date
  end  



end