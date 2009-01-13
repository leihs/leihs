class CategoriesController < FrontendController

  def index
    
    if params[:category_id]
      id = params[:category_id].to_i
      if id == 0 
        @categories = Category.roots
  #old#      c = current_user.categories.roots
  #old#      c = current_user.all_categories & Category.roots
      else
        @categories = Category.find(id).children
  #old#      categories = current_user.categories & Category.find(id).children # TODO scope only children Category (not ModelGroup)
  #old#      categories = current_user.categories.find(id).children
  #old#      categories = current_user.all_categories.find(id).children
      end
    else
      @categories = Category.search(params[:query], :page => params[:page], :per_page => $per_page)
    end

    respond_to do |format|
      format.ext_json { render :json => @categories.to_json(:methods => [[:text, id],
                                                                         :leaf,
                                                                         :real_id],
                                                            :except => [:id]) }
      format.auto_complete {}
    end
  end

end
  
