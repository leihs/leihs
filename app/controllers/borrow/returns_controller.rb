class Borrow::ReturnsController < Borrow::ApplicationController

  def index
    @grouped_lines = Hash[current_user.contract_lines.signed.sort.group_by{|l| [l.end_date, l.inventory_pool] }.sort]
  end

end
