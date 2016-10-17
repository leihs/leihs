module Procurement
  class CategoryPolicy < DefaultPolicy
    def index?
      admin?
    end

    def new?
      admin?
    end

    def create?
      admin?
    end

    def edit?
      admin?
    end

    def update?
      admin?
    end

    def destroy?
      admin?
    end

    def inspectable_by_user?
      record.inspectable_by?(user)
    end
  end
end
