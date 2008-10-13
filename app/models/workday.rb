class Workday < ActiveRecord::Base
  belongs_to :inventory_pool
  
  def is_open_on?(date)
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
end
