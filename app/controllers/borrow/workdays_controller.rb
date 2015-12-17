class Borrow::WorkdaysController < Borrow::ApplicationController

  def index
    @workdays = current_user.inventory_pools.map(&:workday)
  end
end
