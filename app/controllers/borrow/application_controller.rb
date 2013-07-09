class Borrow::ApplicationController < ApplicationController

  layout "borrow"

  before_filter :require_customer, :load_current_order, :redirect_if_order_timed_out, :init_breadcrumbs

  def start
    @categories = (current_user.all_categories & Category.roots).sort
  end

  private

  def require_customer; require_role "customer"; end

  def load_current_order
    @order = current_user.get_current_order
  end

  def redirect_if_order_timed_out
    return if [borrow_order_timed_out_path, borrow_order_remove_path].include? request.path
    redirect_to borrow_order_timed_out_path if @order.lines.count > 0 and (Time.now - @order.updated_at) > 24.hours
  end

  def init_breadcrumbs 
    @bread_crumbs = BreadCrumbs.new params
  end

  def set_pagination_header(paginated_active_record)
    headers["X-Pagination"] = {
      total_count: paginated_active_record.count,
      per_page: paginated_active_record.per_page,
      offset: paginated_active_record.offset
    }.to_json
  end

end
