module LeihsAdmin
  class AdminController < ActionController::Base
    include MainHelpers

    before_action do
      not_authorized!(redirect_path: main_app.root_path) unless admin?
    end

  end
end
