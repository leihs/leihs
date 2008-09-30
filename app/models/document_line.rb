# Superclass for OrderLine and ContractLine
class DocumentLine < ActiveRecord::Base
  self.abstract_class = true
  
  before_validation_on_create :set_defaults
  validate :date_sequence  
  validates_numericality_of :quantity, :greater_than_or_equal_to => 0, :only_integer => true 

###############################################  
  
  def self.current_and_future_reservations(model_id, inventory_pool, document_line = nil, date = Date.today)
    
    is_order_line = (document_line and document_line.is_a?(OrderLine))
    is_contract_line = (document_line and document_line.is_a?(ContractLine))
    cl = ContractLine.find(:all,
                           :joins => :contract,
                           :conditions => ['model_id = ? AND returned_date IS NULL AND contract_lines.id <> ? AND contracts.inventory_pool_id = ?',
                                                  model_id, (is_contract_line ? document_line.id : 0), inventory_pool.id])
    ol = OrderLine.find(:all,
                        :joins => :order,
                        :conditions => ["model_id = :model_id 
                                            AND ((start_date <= :date AND end_date >= :date) OR start_date > :date) 
                                            AND order_lines.id <> :order_line_id 
                                            AND (orders.status_const = :submitted
                                                            OR (orders.id = :current_order_id AND orders.status_const = :new_order))
                                            AND order_lines.inventory_pool_id = :inventory_pool",
                                         { :model_id => model_id, 
                                           :date => date,
                                           :order_line_id => (is_order_line ? document_line.id : 0), 
                                           :submitted => Order::SUBMITTED, 
                                           :current_order_id => (is_order_line ? document_line.order_id : 0),
                                           :new_order => Order::NEW, 
                                           :inventory_pool => inventory_pool.id}
                                        ])
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
