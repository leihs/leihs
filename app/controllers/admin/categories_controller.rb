class Admin::CategoriesController < Admin::AdminController

  before_filter :pre_load

  def index
    if @model
      categories = @model.categories
    else
      categories = Category
    end    
    
    unless params[:query].blank?
      @categories = categories.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
      @categories = categories.paginate :page => params[:page], :per_page => $per_page      
    end
  end
  
  def show
    @category = Category.find(params[:id])
  end

  def destroy
    if @category.models.empty?
      @category.destroy
      redirect_to admin_categories_path
    else
      @category.errors.add_to_base _("The Category must be empty")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) if params[:id]
    @model = Model.find(params[:model_id]) if params[:model_id]
  end


end
  
