# QtyPeriod represents a time stretch over which
# some thing is available in the same quantity
#
# If an and_date is nil, then it is assumed that
# the period has no end, in other words, that it's
# infinitely long.
#
# If you want to represent a longer period with multiple
# time stretches of varying item availability, then use
# the #QtyPeriods class.
#
# *ATTENTION*: nil start_dates are currently NOT supported  
#
class QtyPeriod
  
  attr_accessor :start_date, :end_date, :quantity

  def initialize(quantity, start_date, end_date)
# TODO 0409**    
#   @start_date = @end_date if !@end_date.nil? and @end_date < @start_date
    @start_date = start_date
    @end_date = end_date
    @quantity = quantity
  end

  # used for sorting
  #
  def <=>(other)
    if self.start_date == other.start_date
      # end_dates can be nil
      if self.end_date.nil? && other.end_date.nil?
        return 0
      elsif self.end_date.nil?
        return 1
      elsif other.end_date.nil?
        return -1
      else
        self.end_date <=> other.end_date
      end
    else
      self.start_date <=> other.start_date
    end
  end

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
  
end

# QtyPeriods represents multiple #QtyPeriod time stretches.
#
# QtyPeriods is used by #Availablity to return a list of time stretches
# of identical identities of some item.
#
class QtyPeriods < Array
  
  # add new #QtyPeriod to the #QtyPeriods #Array 
  # if two subsequent #QtyPeriod with the same starting date are added,
  # then only the last #QtyPeriod survives. In other words it is
  # assumed that the last added #QtyPeriod is the correct one.
  #
  # TODO 2502** merge also returning dates
  #
  def << (quantity_per_interval)
    pop if !empty? && last.start_date == quantity_per_interval.start_date
    super
  end
end

# Abstraction for calculations of availabilites of #Model s. I.e. how many
# #Items of some #Model are there over some period of time? The public
# instance methods either return a period count or a #QtyPeriods #Array.
#
class Availability

  # "symbolic" array indexes
  DATE=0
  QUANTITY=1
  PERIOD_END=2

  attr_accessor :quantity
  
  # :nodoc: TODO: it's ugly that one needs to give start_date to the constructor.
  #               It's only used to cut off stray periods that start before the
  #               date of interest.
  #
  def initialize(max_quantity, start_date, model, reservations)
    @quantity = max_quantity
    @start_date = start_date
    @model = model
    
    @availability_changes = [] # [ [DATE, QUANTITY], [DATE, QUANTITY], .. ] f.ex. [ ["8-2-2010", -1], ... ]
    reservations.each do | reservation |
      add_availability_change( @availability_changes, reservation)
    end
    @availability_changes.sort! {|x, y| x[0] <=> y[0] }
    
  end

  # Answers the question "when do I have how many #Items of #Model available".
  # Returns #QtyPeriods of the availability of a model
  # 
  # @availability_changes must be in a sorted state before calling periods
  # in order to function properly! This is usually assured by the constructor,
  # but be ware when messing with this method or the class.
  #
  def periods
    available_in_periods = QtyPeriods.new
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
      
      # we're not interested in periods that end before our start_date
      # this is the case for reservations that start on the start_date and
      # thus the first period ends just one day before our start date
      if end_of_period >= @start_date
        available_in_periods << QtyPeriod.new(current_quantity, start_of_period, end_of_period)
      end
      
      # item only becomes available again on next day
      start_of_period = end_of_period + 1.day
      current_quantity = current_quantity + availability_change[QUANTITY]
    end
    
    available_in_periods << QtyPeriod.new(current_quantity, start_of_period, nil)
    available_in_periods
  end

  # only used by cucumber tests when tpo wrote this comment
  def period_for(date)
    date = date.to_date
    periods.each do |period|
      start_date = period.start_date
      end_date = period.end_date if period.end_date
      return period if start_date <= date && (end_date.nil? || end_date >= date)
    end
    nil
  end

  # how many items of #Model can I borrow at most over the given period?
  #
  def maximum_available_in_period(start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date
    maximum_available = @quantity
    periods.each do |period|
      if period.is_part_of?(start_date, end_date) || period.encloses?(start_date, end_date) || period.start_date_in?(start_date, end_date) || period.end_date_in?(start_date, end_date)
        maximum_available = period.quantity if period.quantity < maximum_available
      end
    end
    maximum_available
  end

############################################################################

  private 

  def add_availability_change( availability_changes, reservation)
    # decrease
    availability_changes << [reservation.start_date.to_date, -reservation.quantity]

    # increase
    availability_changes << [ reservation.end_date.to_date, reservation.quantity] unless reservation.is_late?(@start_date)
  end

  def is_returning?(quantity)
    quantity > 0
  end
  
end
