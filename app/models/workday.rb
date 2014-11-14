class Workday < ActiveRecord::Base

  belongs_to :inventory_pool, inverse_of: :workday

  serialize :max_visits, Hash

  # deprecated
  DAYS = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

  # better
  WORKDAYS = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
  
  def is_open_on?(date)
    
    return false if date.nil?
    
    case date.wday
    when 1
      return monday
    when 2
      return tuesday
    when 3
      return wednesday
    when 4
      return thursday
    when 5
      return friday
    when 6
      return saturday
    when 0
      return sunday
    else
      return false #Should not be reached
    end
  end
  
  def closed_days
    days = []
    days << 0 unless sunday
    days << 1 unless monday
    days << 2 unless tuesday
    days << 3 unless wednesday
    days << 4 unless thursday
    days << 5 unless friday
    days << 6 unless saturday
    days
  end

  def workdays=(wdays)
    wdays.each_pair do |k,v|
      write_attribute(WORKDAYS[k.to_i], v["open"].to_i)
      max_visits[k.to_i] = v["max_visits"].blank? ? nil : v["max_visits"].to_i
    end
  end

  def max_visits_on(weekday_number)
    max_visits[weekday_number]
  end

  def total_visits_by_date
    (inventory_pool.visits + inventory_pool.potential_visits).group_by(&:date)
  end

  def reached_max_visits
    dates = []
    total_visits_by_date.each_pair do |date, visits|
      dates << date if not date.past? and max_visits_on(date.wday) and visits.size >= max_visits_on(date.wday)
    end
    dates.sort
  end

end

