module LeihsAdmin
  class AdminController < ActionController::Base
    include MainHelpers

    before_filter do
      not_authorized!(redirect_path: main_app.root_path) unless is_admin?
    end

  end
end

