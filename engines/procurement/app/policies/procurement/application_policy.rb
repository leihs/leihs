module Procurement
  class ApplicationPolicy
    attr_reader :user

    # application is a dummy argument in order to
    # make headless policies work in pundit due to
    # the argument arity
    def initialize(user, _application = nil)
      @user = user
    end

    def authenticated?
      not user.nil?
    end

    def admins_defined?
      Access.admins.exists?
    end

    def current_budget_period_defined?
      BudgetPeriod.current
    end

    def admin?
      Access.admin?(user)
    end

    def procurement_or_leihs_admin?
      admin? \
        or (Access.admins.empty? and leihs_admin?)
    end

    def procurement_requester?
      Access.requesters.where(user_id: user).exists?
    end

    def procurement_inspector?
      Procurement::Category.inspector_of_any_category?(user)
    end

    def procurement_admin?
      Procurement::Access.admin?(user)
    end

    def procurement_any_access?
      procurement_requester? \
        or procurement_inspector? \
        or procurement_admin? \
        or procurement_or_leihs_admin?
    end

    def leihs_admin?
      user.has_role? :admin
    end
  end
end
