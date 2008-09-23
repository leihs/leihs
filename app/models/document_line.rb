# Superclass for OrderLine and ContractLine
class DocumentLine < ActiveRecord::Base
  self.abstract_class = true
  
  before_validation_on_create :set_defaults
  validate :date_sequence  
  validates_numericality_of :quantity, :greater_than_or_equal_to => 0, :only_integer => true 

###############################################  
  
  def self.current_and_future_reservations(model_id, inventory_pool, document_line = nil, date = Date.today)
    cl = ContractLine.find(:all,
                           :joins => :contract,
                           :conditions => ['model_id = ? AND returned_date IS NULL AND contract_lines.id <> ? AND contracts.inventory_pool_id = ?',
                                                  model_id, (document_line ? document_line.contract_to_exclude : 0), inventory_pool.id])
    ol = OrderLine.find(:all,
                        :joins => :order,
                        :conditions => ['model_id = ? AND ((start_date <= ? AND end_date > ?) OR start_date > ?) AND order_lines.id <> ? AND orders.status_const = ? AND orders.inventory_pool_id = ?',
                                         model_id, date, date, date, (document_line ? document_line.order_to_exclude : 0), Order::SUBMITTED, inventory_pool.id])
    cl + ol
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.start_date <=> other.start_date
  end

  def available?
    model.maximum_available_in_period_for_document_line(start_date, end_date, self) >= quantity
  end
  
  private
  
  def set_defaults
    self.start_date ||= Date.today
    self.end_date ||= Date.today
  end

  def date_sequence
    # OPTIMIZE strange behavior: in some cases, this error raises when shouldn't 
    errors.add_to_base(_("Start Date must be before End Date")) if end_date < start_date
   #TODO: Think about this a little bit more.... errors.add_to_base(_("Start Date cannot be a past date")) if start_date < Date.today
  end


end
