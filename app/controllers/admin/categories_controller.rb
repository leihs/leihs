class Admin::CategoriesController < Admin::AdminController

  before_filter :pre_load

  def index
    unless params[:query].blank?
      @categories = Category.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
      @categories = Category.paginate :page => params[:page], :per_page => $per_page      
    end
  end
  
  def show
    @category = Category.find(params[:id])
  end

  def models
    
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) if params[:id]
  end


end
  
