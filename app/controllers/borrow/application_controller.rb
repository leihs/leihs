class Borrow::ApplicationController < ApplicationController

  layout "borrow"

  before_filter :require_customer, :init_breadcrumbs

  def start
    @categories = (current_user.all_categories & Category.roots).sort
  end

  private

  def require_customer; require_role "customer"; end

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
