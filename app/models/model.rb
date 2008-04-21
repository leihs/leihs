class Model < ActiveRecord::Base
  has_many :items
  has_many :order_lines
  has_many :properties
  has_many :accessories

  has_and_belongs_to_many :packages
    
  #TODO: Relation to Inventory Pool?

  acts_as_ferret :fields => [ :name ] #, :store_class_name => true

  
  def availability(current_time = DateTime.now)
    a = create_availability(current_time).periods
  end
  
  def availabilities(start_date, end_date, current_time = DateTime.now)
    a = create_availability(current_time)
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
  
  def maximum_available(date, current_time = DateTime.now)
    create_availability(current_time).period_for(date).quantity
  end
  
  def maximum_available_in_period(start_date, end_date, current_time = DateTime.now)
    if (start_date.nil? && end_date.nil?)
      return items.size
    else
      create_availability(current_time).maximum_available_in_period(start_date, end_date)
    end
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
