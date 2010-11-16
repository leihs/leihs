# == Schema Information
#
# Table name: workdays
#
#  id                :integer(4)      not null, primary key
#  inventory_pool_id :integer(4)
#  monday            :boolean(1)      default(TRUE)
#  tuesday           :boolean(1)      default(TRUE)
#  wednesday         :boolean(1)      default(TRUE)
#  thursday          :boolean(1)      default(TRUE)
#  friday            :boolean(1)      default(TRUE)
#  saturday          :boolean(1)      default(FALSE)
#  sunday            :boolean(1)      default(FALSE)
#

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
end

