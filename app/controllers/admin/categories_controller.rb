class Admin::CategoriesController < Admin::AdminController


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


end
  
