class Backend::CategoriesController < Backend::BackendController
  # TODO require_role ?
  
  def index
    @categories = Category.roots
  end

  
  def expand_category
    @categories = Category.find(params[:id]).children if params[:id]
    render :partial => 'categories'
  end  
  
  
end
