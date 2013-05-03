class Workday < ActiveRecord::Base

  belongs_to :inventory_pool
  
  DAYS = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
  
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

  def open!(day_number)
    case day_number
    when 1
      self.monday = true
    when 2
      self.tuesday = true
    when 3
      self.wednesday = true
    when 4
      self.thursday = true
    when 5
      self.friday = true
    when 6
      self.saturday = true
    when 0
      self.sunday = true
    end
  end

  def closed!(day_number)
    case day_number
    when 1
      self.monday = false
    when 2
      self.tuesday = false
    when 3
      self.wednesday = false
    when 4
      self.thursday = false
    when 5
      self.friday = false
    when 6
      self.saturday = false
    when 0
      self.sunday = false
    end
  end
end

