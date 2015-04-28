class Manage::WorkdaysController < Manage::ApplicationController

  before_filter do
    @workday = current_inventory_pool.workday
    @holidays = current_inventory_pool.holidays.future
    @holiday = Holiday.new
  end

  def index
    @workday = current_inventory_pool.workday
  end
  
  def close
    update_workday(params[:day], false) 
    redirect_to action: 'index'
  end
  
  def open
    update_workday(params[:day], true)
    redirect_to action: 'index'
  end
  
  def add_holiday
    current_inventory_pool.holidays.create(params[:holiday]) and redirect_to action: 'index'
  end
  
  def delete_holiday
    current_inventory_pool.holidays.delete(Holiday.find(params[:id])) and redirect_to action: 'index'
  end
  
  private 
  
  def update_workday(day, is_open)
    @workday.update_attributes(params[:day] => is_open) if Workday::DAYS.include?(params[:day])    
  end
end