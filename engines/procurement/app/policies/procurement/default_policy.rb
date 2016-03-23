module Procurement
  class DefaultPolicy
    attr_reader :user, :record

    ############# PUNDIT DEFAULTS ##################

    def initialize(user, record = nil)
      raise Pundit::NotAuthorizedError, 'You are not logged in' unless user
      @user = user
      @record = record
    end

    def index?
      false
    end

    def show?
      scope.where(id: record.id).exists?
    end

    def create?
      false
    end

    def new?
      create?
    end

    def update?
      false
    end

    def edit?
      update?
    end

    def destroy?
      false
    end

    def scope
      Pundit.policy_scope!(user, record.class)
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope
      end
    end

    ################################################

    def admin?
      Pundit.policy!(user, 'procurement/application'.to_sym)
        .admin?
    end

    def procurement_or_leihs_admin?
      Pundit.policy!(user, 'procurement/application'.to_sym)
        .procurement_or_leihs_admin?
    end

    def procurement_requester?
      Pundit.policy!(user, 'procurement/application'.to_sym)
        .procurement_requester?
    end

    def leihs_admin?
      Pundit.policy!(user, 'procurement/application'.to_sym)
        .leihs_admin?
    end
  end
end
