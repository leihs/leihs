class Borrow::ApplicationController < ApplicationController

  layout "borrow"

  before_filter :require_customer, :redirect_if_order_timed_out, :init_breadcrumbs

  def start
    current_user_categories = current_user.all_categories
    @categories = (current_user_categories & Category.roots).sort
    @child_categories = @categories.map {|c| (current_user_categories & c.children).sort}
    @any_template = current_user.templates.any?
  end

  def current_order
    @current_order ||= current_user.get_current_order
  end
  helper_method :current_order

  def refresh_timeout
    # ok, refreshed
    respond_to do |format|
      format.html {render :nothing => true}
      format.json do
        render :json => { date: current_user.get_current_order.updated_at }
      end
    end
  end

  private

  def require_customer; require_role "customer"; end

  def redirect_if_order_timed_out
    return if request.format == :json or
              [borrow_order_timed_out_path,
               borrow_order_delete_unavailables_path,
               borrow_order_remove_path,
               borrow_order_remove_lines_path,
               borrow_order_lines_change_time_range_path].include? request.path
    if current_order.lines.count > 0 and current_order.timeout? and current_order.lines.any? {|l| not l.available? }
      redirect_to borrow_order_timed_out_path
    else
      current_order.touch
    end
  end

  def init_breadcrumbs 
    @bread_crumbs = BreadCrumbs.new params.delete("_bc")
  end

  def set_pagination_header(paginated_active_record)
    headers["X-Pagination"] = {
      total_count: paginated_active_record.count,
      per_page: paginated_active_record.per_page,
      offset: paginated_active_record.offset
    }.to_json
  end

end
