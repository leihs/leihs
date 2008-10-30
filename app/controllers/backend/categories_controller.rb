class Backend::CategoriesController < Backend::BackendController

  before_filter :pre_load

  def index
    if @model
      # TODO 30** all_categories
      categories = @model.categories
    else
      categories = Category
    end    
    
    unless params[:query].blank?
      # TODO 30** searching through backend/models
      @categories = categories.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
      @categories = categories.paginate :page => params[:page], :per_page => $per_page      
    end
  end
  
  def show
    @category = Category.find(params[:id])
  end


#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]
  end


end
  
