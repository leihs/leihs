class FrontendController < ApplicationController

  require_role "customer"

  layout "frontend3"

  def index
    @user = current_user
    @current_categories = (current_user.all_categories & Category.roots).sort
    @missing_fields = @user.authentication_system.missing_required_fields(@user)
    render :template => "users/show", :layout => "frontend_2010" unless @missing_fields.empty?
  end

end
