class Borrow::ApplicationController < ApplicationController

  layout "borrow"

  before_filter :check_maintenance_mode, except: :maintenance
  before_filter :require_customer, :redirect_if_order_timed_out, :init_breadcrumbs, :get_current_delegated_user

  def root
    current_user_categories = current_user.all_categories
    @categories = (current_user_categories & Category.roots).sort
    @child_categories = @categories.map {|c| (current_user_categories & c.children).sort}
    @any_template = current_user.templates.any?
  end

  def unsubmitted_contracts
    @unsubmitted_contracts ||= current_user.contracts.unsubmitted
  end
  helper_method :unsubmitted_contracts

  def refresh_timeout
    # ok, refreshed
    respond_to do |format|
      format.html {render :nothing => true}
      if unsubmitted_contracts.empty?
        date = Time.now
      else
        date = unsubmitted_contracts.first.updated_at
      end

      format.json do
        render :json => { date: date }
      end
    end
  end

  private

  def check_maintenance_mode
    redirect_to borrow_maintenance_path if Setting::DISABLE_BORROW_SECTION
  end

  def require_customer
    require_role :customer
  end

  def redirect_if_order_timed_out
    return if request.format == :json or
              [borrow_order_timed_out_path,
               borrow_order_delete_unavailables_path,
               borrow_order_remove_path,
               borrow_order_remove_lines_path,
               borrow_change_time_range_path].include? request.path
    if current_user.timeout? and unsubmitted_contracts.flat_map(&:lines).any? {|l| not l.available? }
      redirect_to borrow_order_timed_out_path
    else
      unsubmitted_contracts.each do |contract|
        contract.touch
      end
    end
  end

  def init_breadcrumbs 
    @bread_crumbs = BreadCrumbs.new params.delete("_bc")
  end

  def get_current_delegated_user
    @current_delegated_user ||= User.find(session[:delegated_user_id]) if !!session[:delegated_user_id]
  end
end
