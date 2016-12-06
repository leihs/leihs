module Procurement
  class ApplicationController < ActionController::Base
    include MainHelpers
    include Pundit

    helper_method :procurement_requester?
    helper_method :procurement_inspector?
    helper_method :procurement_admin?

    before_action do
      authorize 'procurement/application'.to_sym, :authenticated?
      authorize 'procurement/application'.to_sym, :procurement_any_access?
    end

    # defined in a separate before_action as it is skiped in
    # another controller
    before_action :authorize_if_admins_exist, except: :root

    rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized

    def root
      authorize 'procurement/application'.to_sym, :current_budget_period_defined?

      redirect_to overview_requests_path if current_user
    end

    private

    def authorize_if_admins_exist
      authorize 'procurement/application'.to_sym, :admins_defined?
    end

    def handle_not_authorized(exception)
      case exception.query
      when :authenticated?
        redirect_to main_app.login_path

      when :procurement_any_access?
        redirect_to main_app.root_path

      when :admins_defined?
        flash.now[:error] = _('No admins defined yet')
        render action: :root

      when :current_budget_period_defined?
        flash.now[:error] = _('Current budget period not defined yet')
        render action: :root

      when :not_past?
        flash.now[:error] = _('The budget period is closed')
        render action: :root

      else
        flash.now[:error] = _('You are not authorized for this action.')
        render action: :root

      end
    end

    def procurement_or_leihs_admin?
      ApplicationPolicy.new(current_user).procurement_or_leihs_admin?
    end

    def procurement_requester?
      ApplicationPolicy.new(current_user).procurement_requester?
    end

    def procurement_inspector?
      ApplicationPolicy.new(current_user).procurement_inspector?
    end

    def procurement_admin?
      ApplicationPolicy.new(current_user).procurement_admin?
    end

  end
end
