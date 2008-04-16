class Availability
  
  attr_accessor :start_date, :end_date, :quantity, :model
  
  def initialize(max_quantity, start_date = DateTime.now, end_date = nil)
    @start_date = start_date
    @end_date = end_date
    @quantity = max_quantity
    @events = []
  end
  
  def forever?
    end_date.nil?
  end
  
  def periods
    periods = []
    last_date = @start_date
    last_quantity = @quantity
    
    @events.each do |event|
      date_of_event = event[0]
      if is_returnal?(event[1])
        date_of_event = date_of_event + @model.maintenance_period.day
      else
        date_of_event = date_of_event - 1.day
      end
      periods << Availability.new(last_quantity, last_date, date_of_event)
      last_date = date_of_event + 1.day  
      last_quantity = last_quantity + event[1]
    end
    
    periods << (periods.size == 0 ? self : Availability.new(last_quantity, last_date, nil))
    periods
  end

  def period_for(date)
    date = as_date(date)
    periods.each do |period|
      start_date = as_date(period.start_date)
      end_date = as_date(period.end_date) if period.end_date
      return period if start_date <= date && (end_date.nil? || end_date >= date)
    end
    nil
  end

  def maximum_available_in_period(start_date, end_date)
    start_date = as_date(start_date)
    end_date = as_date(end_date)
    maximum_available = @quantity
    periods.each do |period|
      if period.is_part_of(start_date, end_date) || period.encloses(start_date, end_date) || period.start_date_in(start_date, end_date) || period.end_date_in(start_date, end_date)
        maximum_available = period.quantity if period.quantity < maximum_available
      end
    end
    maximum_available
  end

  def is_part_of(start_date, end_date)
    return false if self.end_date.nil?
    self.start_date >= start_date && self.end_date <= end_date
  end
  
  def encloses(start_date, end_date)
    self.start_date <= start_date && (self.end_date.nil? || self.end_date >= end_date)
  end
  
  def start_date_in(start_date, end_date)
    self.start_date >= start_date && self.start_date <= end_date
  end
  
  def end_date_in(start_date, end_date)
    return false if self.end_date.nil?
    self.end_date >= start_date && self.end_date <= end_date
  end
  
  

  def reservations(reservations)
    reservations.each do | reservation |
      reserve(reservation.quantity, reservation.start_date, reservation.end_date)
    end
    
  end
  
  def reserve(quantity, from, to)
    remove(quantity, from)
    add(quantity, to)
    @events = @events.sort do |x, y|
      x[0] <=> y[0]
    end
  end
  
  def remove(quantity, on)
    @events << [Date.new(on.year, on.month, on.day), -quantity]
  end
  
  def add(quantity, on)
    @events << [Date.new(on.year, on.month, on.day), quantity]
  end
  
  private 
  
  def is_returnal?(quantity)
    quantity > 0
  end
  
  def as_date(date)
    Date.new(date.year, date.month, date.day)
  end
  
end