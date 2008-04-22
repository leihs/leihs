class Model < ActiveRecord::Base
  has_many :items
  has_many :order_lines
  has_many :properties
  has_many :accessories

  has_and_belongs_to_many :packages
    
  #TODO: Relation to Inventory Pool?

  acts_as_ferret :fields => [ :name ] #, :store_class_name => true

  
  def availability(order_line_id = 0, current_time = DateTime.now)
    a = create_availability(current_time, order_line_id).periods
  end
  
  def availabilities(start_date, end_date, order_line_id = 0, current_time = DateTime.now)
    a = create_availability(current_time, order_line_id)
    ret = []
    start_date.upto(end_date) do |d|
      period = a.period_for(d)
      if period.nil?
        ret << [d, 0]
      else
        ret << [d, period.quantity]
      end
    end
    ret
  end
  
  def maximum_available(date, order_line_id = 0, current_time = DateTime.now)
    create_availability(current_time, order_line_id).period_for(date).quantity
  end
  
  def maximum_available_in_period(start_date, end_date, order_line_id = 0, current_time = DateTime.now)
    if (start_date.nil? && end_date.nil?)
      return items.size
    else
      create_availability(current_time, order_line_id).maximum_available_in_period(start_date, end_date)
    end
  end  
  
  private 
  
  def create_availability(current_time, order_line_id = 0)    
    i = self.items.find(:all, :conditions => ['status = ?', Item::AVAILABLE])
    a = Availability.new(i.size)
    a.model = self
    a.reservations(OrderLine.current_and_future_reservations(id, order_line_id, current_time))
    a
  end
end
