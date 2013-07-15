class Borrow::HolidaysController < Borrow::ApplicationController
  
  def index
    @holidays = current_user.inventory_pools.map(&:holidays).flatten
  end
end
