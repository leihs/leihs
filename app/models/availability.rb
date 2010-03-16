
# Availability of Models
#
class Availability

  # "symbolic" array indexes
  DATE=0
  QUANTITY=1
  PERIOD_END=2

  attr_accessor :start_date, :end_date, :quantity, :model
  
  def initialize(max_quantity, start_date = Date.today, end_date = nil, current_date = nil)
    @start_date = start_date
    @end_date = end_date
# TODO 0409**    
#    @start_date = @end_date if !@end_date.nil? and @end_date < @start_date
    @quantity = max_quantity
    @current_date = current_date
    @availability_changes = []    # [ [DATE, QUANTITY], [DATE, QUANTITY], .. ] f.ex. [ ["8-2-2010", -1], ... ]
  end

  # compares two objects in order to sort them
  def <=>(other)
    if self.start_date == other.start_date
      self.end_date <=> other.end_date
    else
      self.start_date <=> other.start_date
    end
  end

  # :nodoc:  @availability_changes needs to be sorted!
  #
  def periods
    availabilities = []
    start_of_period = @start_date
    current_quantity = @quantity
    
    @availability_changes.each do |availability_change|
      end_of_period = availability_change[DATE]
      if is_returning?(availability_change[QUANTITY])
        # item will stay unavailable while being maintained
        end_of_period = end_of_period + @model.maintenance_period.day 
      else
        # item got borrowed today so the old item quantity ends yesterday
        end_of_period = end_of_period - 1.day
      end

      # TODO 2502** merge returning dates
      availabilities.delete_if {|a| a.start_date == start_of_period }
      
      availabilities << Availability.new(current_quantity, start_of_period, end_of_period)
      # item only becomes available again on next day
      start_of_period = end_of_period + 1.day
      current_quantity = current_quantity + availability_change[QUANTITY]
    end
    
    availabilities << (availabilities.size == 0 ? self : Availability.new(current_quantity, start_of_period, nil))
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

  # only used by cucumber tests when tpo wrote this comment
  def forever?
    end_date.nil?
  end

  # TODO rename to ingest_reservations
  def reservations(reservations)
    reservations.each do | reservation |
      add_availability_change(reservation)
    end
    @availability_changes = @availability_changes.sort {|x, y| x[0] <=> y[0] }
  end

############################################################################

  private 

  def add_availability_change(reservation)
    # decrease
    @availability_changes << [reservation.start_date.to_date, -reservation.quantity]

    # increase
    @availability_changes << [ reservation.end_date.to_date, reservation.quantity] unless reservation.is_late?(@current_date)
  end

  def is_returning?(quantity)
    quantity > 0
  end
  
  def as_date(date)
    Date.new(date.year, date.month, date.day)
  end
  
end
