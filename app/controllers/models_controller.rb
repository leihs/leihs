class ModelsController < ApplicationController
  prepend_before_filter :login_required

  def index
    
    if params[:text]
      @models = Model.find_by_contents("*" + params[:text] + "*")
    else  
      @models = current_user.inventory_pools.collect(&:models).flatten
      @models += Model.packages # OPTIMIZE
    end

    # OPTIMIZE
    if params[:id]
      category = Category.find(params[:id])
      @categories = [category] + category.children.recursive.to_a
    else
#      @categories = Category.roots
      @categories = @models.collect(&:categories).flatten.uniq
      parents = []
      @categories.each do |c|
          parents << c.parents.recursive.to_a   
      end
      @categories << parents
      @categories.flatten!.uniq!
    end

    @ancestor_ids = (params[:ancestor_ids] ? params[:ancestor_ids] : 0) # OPTIMIZE

  end

  def categories
    # OPTIMIZE
    #@category_children = Category.roots
    index
    @category_children = @categories
    
#    @ancestor_ids = (params[:ancestor_ids] ? params[:ancestor_ids] : 0) # OPTIMIZE
    render :partial => 'categories'
  end
  
  def expand_category
    @category_children = Category.find(params[:id]).children if params[:id]
#    @ancestor_ids = (params[:ancestor_ids] ? params[:ancestor_ids] : 0) # OPTIMIZE
#    render :partial => 'categories'

    index
    render :update do |page|
      page.replace_html "category_children_#{@ancestor_ids}", :partial => 'categories'
      page.replace_html "categories", :partial => 'categories_and_models'
    end
  end  

  def search
    if request.post?
      if params[:source_controller].include?("backend/") #current_inventory_pool
        # Backend
        @search_result = current_inventory_pool.models.find_by_contents("*" + params[:text] + "*")
      else
        # Frontend
        # TODO scope models visible by current_user
        @search_result = Model.find_by_contents("*" + params[:text] + "*")
      end
    end

    # TODO @categories = Category.roots
    
    render  :layout => $modal_layout_path
  end  

end
