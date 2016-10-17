module Procurement
  class SettingPolicy < DefaultPolicy
    def edit?
      admin?
    end

    def create?
      admin?
    end
  end
end
