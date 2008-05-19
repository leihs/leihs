# Superclass for OrderLine and ContractLine
class DocumentLine < ActiveRecord::Base
  self.abstract_class = true
  
  belongs_to :model

  
  before_validation_on_create :set_defaults
  validate :date_sequence


  # compares two objects in order to sort the
  def <=>(other)
    self.start_date <=> other.start_date
  end

  def available?
    model.maximum_available_in_period(start_date, end_date, id) >= quantity
  end
  


  private
  
  def set_defaults
    self.start_date ||= Date.today
    self.end_date ||= Date.today
    self.quantity = [quantity, 1].max
  end

  def date_sequence
    errors.add_to_base(_("Start Date must be before End Date")) if end_date < start_date
   #TODO: Think about this a little bit more.... errors.add_to_base(_("Start Date cannot be a past date")) if start_date < Date.today
  end


end
