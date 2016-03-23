module Procurement
  class OrganizationPolicy < DefaultPolicy
    def index?
      admin?
    end
  end
end
