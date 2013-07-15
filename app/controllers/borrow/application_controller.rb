class Borrow::ApplicationController < ApplicationController

  layout "borrow"

  before_filter :require_customer, :redirect_if_order_timed_out, :init_breadcrumbs

  def start
    @categories = (current_user.all_categories & Category.roots).sort
  end

  def current_order
    @current_order ||= current_user.get_current_order
  end
  helper_method :current_order

  private

  def require_customer; require_role "customer"; end

  def redirect_if_order_timed_out
    return if [borrow_order_timed_out_path, borrow_order_remove_path].include? request.path
    redirect_to borrow_order_timed_out_path if current_order.lines.count > 0 and (Time.now - current_order.updated_at) > 24.hours
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
