class Model < ActiveRecord::Base
  has_many :items
  has_many :order_lines
  has_many :properties
  has_many :accessories

  has_and_belongs_to_many :packages
    
  #TODO: Relation to Inventory Pool?

  acts_as_ferret :fields => [ :name ] #, :store_class_name => true

  
  def availability(current_time = DateTime.now)
    a = create_availability(current_time)
    a.periods
  end
  
  def maximum_available(date, current_time = DateTime.now)
    a = create_availability(current_time)
    a.period_for(date).quantity
  end
  
  #TODO to implement
  def maximum_available_in_period(start_date, end_date, current_time = DateTime.now)
    maximum_available(start_date)
  end  
  
  private 
  
  def create_availability(current_time)
    
    i = self.items.find(:all, :conditions => ['status = ?', Item::AVAILABLE])
    a = Availability.new(i.size)
    a.model = self
    a.reservations(OrderLine.current_and_future_reservations(id, current_time))
    a
  end
end
