class OrderLine < ActiveRecord::Base
  belongs_to :model
  belongs_to :order
  
  before_validation_on_create :set_defaults
  validate :date_sequence

  
  def self.current_reservations(model_id, date = Date.today)
    OrderLine.find(:all, :conditions => ['model_id = ? and start_date < ? and end_date > ?', model_id, date, date])
  end
  
  def self.future_reservations(model_id, date = Date.today)
    OrderLine.find(:all, :conditions => ['model_id = ? and start_date > ?', model_id, date])
  end
  
  def self.current_and_future_reservations(model_id, order_line_id = 0, date = Date.today)
    OrderLine.find(:all, :conditions => ['model_id = ? and ((start_date < ? and end_date > ?) or start_date > ?) and id <> ?', model_id, date, date, date, order_line_id])
  end


  private
  
 
  def set_defaults
    self.start_date ||= Date.today
    self.end_date ||= Date.today
  end

  def date_sequence
#    if start_date and end_date 
      errors.add_to_base("Start Date must be before End Date") if end_date < start_date
      errors.add_to_base("Start Date cannot be a past date") if start_date < Date.today
#    end
  end

end
