class Borrow::ReturnsController < Borrow::ApplicationController

  def index
    @grouped_lines = Hash[current_user.reservations.signed.sort.group_by{|l| [l.end_date, l.inventory_pool] }.sort]
  end

end
