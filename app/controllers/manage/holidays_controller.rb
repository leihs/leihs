class Manage::HolidaysController < Manage::ApplicationController

  def index
    @holidays = current_inventory_pool.holidays
  end

end
