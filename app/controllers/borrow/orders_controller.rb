class Borrow::OrdersController < Borrow::ApplicationController

  before_filter :only => [:current, :timed_out] do
    @grouped_and_merged_lines = current_order.grouped_and_merged_lines    
  end

  def index
    @orders = current_user.orders.submitted
  end

  def current
  end

  def submit
    current_order.created_at = DateTime.now
    unless current_order.submit(params[:purpose])
      flash[:error] = current_order.errors.full_messages.uniq.join("\n")
      redirect_to borrow_current_order_path
    else
      flash[:notice] = _("The order has been successfully submitted, but is NOT YET CONFIRMED.")
      redirect_to borrow_root_path
    end
  end

  def remove
    current_order.destroy
    redirect_to borrow_root_path
  end

  def remove_lines(line_ids = params[:line_ids])
    lines = current_order.lines.find(line_ids)
    lines.each {|l| current_order.remove_line(l, current_user.id) }
    redirect_to borrow_current_order_path
  end

  def timed_out
    flash[:error] = _("Your order is older than %d minutes, the items are not reserved any more!") % Order::TIMEOUT_MINUTES
    render :current
  end

end
