class OrderLine < ActiveRecord::Base
  belongs_to :model
  belongs_to :order
  
  def self.current_reservations(model_id, date = DateTime.now)
    OrderLine.find(:all, :conditions => ['model_id = ? and start_date < ? and end_date > ?', model_id, date, date])
  end
  
  def self.future_reservations(model_id, date = DateTime.now)
    OrderLine.find(:all, :conditions => ['model_id = ? and start_date > ?', model_id, date])
  end
  
  def self.current_and_future_reservations(model_id, date = DateTime.now)
    OrderLine.find(:all, :conditions => ['model_id = ? and ((start_date < ? and end_date > ?) or start_date > ?)', model_id, date, date, date])
  end
end
