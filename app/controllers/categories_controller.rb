class CategoriesController < FrontendController

  def index

# working here #    
    # OPTIMIZE 0907
    if params[:category_id]
      id = params[:category_id].to_i
      if id == 0
        @categories = (current_user.all_categories & Category.roots).sort
      else
        # TODO scope only children Category (not ModelGroup)
        @categories = (current_user.all_categories & Category.find(id).children).sort
      end
    else
      @categories = Category.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page }
    end

    respond_to do |format|
      format.ext_json { render :json => @categories.to_json(:methods => [[:text, id],
                                                                         :leaf,
                                                                         :real_id],
                                                            :except => [:id]) }
    end
  end

end
  
