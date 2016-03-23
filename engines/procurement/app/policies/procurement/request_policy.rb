module Procurement
  class RequestPolicy < DefaultPolicy
    attr_reader :request_user

    def initialize(user, request_user: nil)
      super(user)
      @request_user = request_user
    end

    def allowed?
      request_user == user or
        Procurement::Group.inspector_of_any_group_or_admin?(user)
    end
  end
end
