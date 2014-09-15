class Workday < ActiveRecord::Base

  belongs_to :inventory_pool, inverse_of: :workday
  
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
    WORKDAYS.each {|workday| write_attribute(workday, wdays.include?(workday) ? true : false)}
  end
    
end

