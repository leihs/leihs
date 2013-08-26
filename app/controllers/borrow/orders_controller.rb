class Borrow::OrdersController < Borrow::ApplicationController

  before_filter :only => [:current, :timed_out] do
    @grouped_and_merged_lines = current_order.grouped_and_merged_lines
    @models = current_order.lines.map(&:model).uniq
    @inventory_pools = current_order.lines.map(&:inventory_pool).uniq
  end

  def index
    @grouped_and_merged_lines = Order.grouped_and_merged_lines_for_collection :start_date, current_user.orders.submitted
  end

  def current
    @lines = current_order.lines
  end

  def submit
    current_order.created_at = DateTime.now
    unless current_order.submit(params[:purpose])
      flash[:error] = current_order.errors.full_messages.uniq.join("\n")
      redirect_to borrow_current_order_path
    else
      flash[:notice] = _("Your order has been successfully submitted, but is NOT YET APPROVED.")
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
    flash[:error] = _("%d minutes passed. The items are not reserved for you any more!") % Order::TIMEOUT_MINUTES
    @timed_out = true
    @lines = current_order.lines.as_json(methods: :available?)
    render :current
  end

  def delete_unavailables
    current_order.lines.each {|l| l.delete unless l.available? }
    redirect_to borrow_current_order_path, flash: {notice: _("Your order has been modified. All reservations are now available.")}
  end

end
