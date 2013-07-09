class Borrow::ToPickUpController < Borrow::ApplicationController

  def index
    @grouped_lines = current_user.contract_lines.to_hand_over.group_by{|l| [l.start_date, l.inventory_pool] }
  end

end
