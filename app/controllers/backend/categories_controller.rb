class Backend::CategoriesController < Backend::BackendController

  before_filter :pre_load

  def index
    if @model
      # TODO 30** all_categories
      categories = @model.categories
    else
      categories = Category
    end    
    
    # TODO 30** searching through backend/models
    @categories = categories.search(params[:query], :page => params[:page], :per_page => $per_page)
  end
  
  def show
    @category = Category.find(params[:id])
  end

#################################################################
# Only for packages 

  def create
    if @model and @category and @model.is_package
      unless @category.models.include?(@model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink
        @category.models << @model
        flash[:notice] = _("Category successfully assigned")
      else
        flash[:error] = _("The model is already assigned to this category")
      end
      redirect_to :action => 'index'
    end
  end

  def destroy
    if @model and @category and @model.is_package
        @category.models.delete(@model)
        flash[:notice] = _("Category successfully removed")
        redirect_to :action => 'index'
    end
  end
  
#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]

    @tabs = []
    @tabs << (@model.is_package ? :package_backend : :model_backend ) if @model
  end


end
  
