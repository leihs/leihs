class CategoriesController < FrontendController

  def index
    @current_categories = (current_user.all_categories & Category.roots).sort
    @missing_fields = current_user.authentication_system.missing_required_fields(current_user)
    render :template => "users/show", :layout => "frontend_2010" unless @missing_fields.empty?
  end

end
  
