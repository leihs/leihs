class ApplicationController < ActionController::Base
  include MainHelpers

  layout 'splash'
  
  def root
    if logged_in?
      flash.keep
      if current_user.has_role?(:admin)
        redirect_to admin.root_path
      elsif current_user.has_role?(:group_manager)
        redirect_to manage_root_path
      else
        redirect_to borrow_root_path
      end
    end
  end

end
