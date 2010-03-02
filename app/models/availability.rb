# Availability of Models
#
class Availability
  
  attr_accessor :start_date, :end_date, :quantity, :model
  
  def initialize(max_quantity, start_date = Date.today, end_date = nil, current_date = nil)
    @start_date = start_date
    @end_date = end_date
# TODO 0409**    
#    @start_date = @end_date if !@end_date.nil? and @end_date < @start_date
    @quantity = max_quantity
    @current_date = current_date
    @events = []
  end

  # compares two objects in order to sort them
  def <=>(other)
    if self.start_date == other.start_date
      self.end_date <=> other.end_date
    else
      self.start_date <=> other.start_date
    end
  end

  # TODO 2502** recheck this method
  def periods
    availabilities = []
    last_date = @start_date
    last_quantity = @quantity
    
    @events.each do |event|
      date_of_event = event[0]
      if is_returnal?(event[1])
        date_of_event = date_of_event + @model.maintenance_period.day 
      else
        date_of_event = date_of_event - 1.day
      end

      # TODO 2502** merge returning dates
      availabilities.delete_if {|a| a.start_date == last_date }
      #
      
      availabilities << Availability.new(last_quantity, last_date, date_of_event)
      last_date = date_of_event + 1.day  
      last_quantity = last_quantity + event[1]
    end
    
    availabilities << (availabilities.size == 0 ? self : Availability.new(last_quantity, last_date, nil))
    availabilities
  end

  # only used by cucumber tests when tpo wrote this comment
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
      if period.is_part_of?(start_date, end_date) || period.encloses?(start_date, end_date) || period.start_date_in?(start_date, end_date) || period.end_date_in?(start_date, end_date)
        maximum_available = period.quantity if period.quantity < maximum_available
      end
    end
    maximum_available
  end

############################################################################

  def is_part_of?(start_date, end_date)
    return false if self.end_date.nil?
    self.start_date >= start_date && self.end_date <= end_date
  end
  
  def encloses?(start_date, end_date)
    self.start_date <= start_date && (self.end_date.nil? || self.end_date >= end_date)
  end
  
  def start_date_in?(start_date, end_date)
    self.start_date >= start_date && self.start_date <= end_date
  end
  
  def end_date_in?(start_date, end_date)
    return false if self.end_date.nil?
    self.end_date >= start_date && self.end_date <= end_date
  end

  # used by availability instances
  # TODO: ?!?
  def is_late?(date)
    false
  end

  # only used by cucumber tests when tpo wrote this comment
  def forever?
    end_date.nil?
  end

  def reservations(reservations)
    reservations.each do | reservation |
      reserve(reservation)
    end
    @events = @events.sort {|x, y| x[0] <=> y[0] }
  end

############################################################################

  private 

  def reserve(reservation)
    # remove
    on = reservation.start_date
    @events << [Date.new(on.year, on.month, on.day), -reservation.quantity]

    # add
    on = reservation.end_date || 10.years.from_now.to_date # emulating infinite future
    @events << [Date.new(on.year, on.month, on.day), reservation.quantity] unless reservation.is_late?(@current_date)
  end
  
  def is_returnal?(quantity)
    quantity > 0
  end
  
  def as_date(date)
    Date.new(date.year, date.month, date.day)
  end
  
end
