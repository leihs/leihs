class Borrow::ReturnsController < Borrow::ApplicationController

  def index
    @grouped_lines = current_user.contract_lines.to_take_back.group_by{|l| [l.end_date, l.inventory_pool] }
  end

end
