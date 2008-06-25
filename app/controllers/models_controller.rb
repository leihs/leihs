class ModelsController < ApplicationController
  prepend_before_filter :login_required

  def index
    
    if params[:text]
      @models = Model.find_by_contents("*" + params[:text] + "*")
    else  
      @models = current_user.inventory_pools.collect(&:models).flatten
    end
    
    @categories = @models.collect(&:categories).flatten.uniq
    parents = []
    @categories.each do |c|
        parents << c.parents.recursive.to_a   
    end
    @categories << parents
    @categories.flatten!.uniq!

    @ancestor_ids = (params[:ancestor_ids] ? params[:ancestor_ids] : 0) # OPTIMIZE

  end

  def categories
    @categories = Category.roots
#    @ancestor_ids = (params[:ancestor_ids] ? params[:ancestor_ids] : 0) # OPTIMIZE
    render :partial => 'categories'
  end
  
  def expand_category
    @categories = Category.find(params[:id]).children if params[:id]
    @ancestor_ids = (params[:ancestor_ids] ? params[:ancestor_ids] : 0) # OPTIMIZE
    render :partial => 'categories'
  end  

  def search
    if request.post?
      @search_result = Model.find_by_contents("*" + params[:text] + "*")
    end

    # TODO @categories = Category.roots
    
    render  :layout => $modal_layout_path
  end  

end
