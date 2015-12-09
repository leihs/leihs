class Manage::WorkdaysController < Manage::ApplicationController

  before_action do
    @workday = current_inventory_pool.workday
    @holidays = current_inventory_pool.holidays.future
    @holiday = Holiday.new
  end

  def index
    @workday = current_inventory_pool.workday
  end

end
