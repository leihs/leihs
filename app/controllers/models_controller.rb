class ModelsController < ApplicationController
  prepend_before_filter :login_required

  def index
    
    if params[:search]
      @models = current_user.models.find_by_contents("*" + params[:search] + "*")
    else  
      @models = current_user.models #old# current_user.inventory_pools.collect(&:models).flatten
#old#      @models += Model.packages # OPTIMIZE
    end

    # OPTIMIZE
    if params[:id]
      category = Category.find(params[:id])
      @categories = [category] # + category.children.recursive.to_a
    else
#      @categories = Category.roots
      @categories = @models.collect(&:model_groups).flatten.uniq
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
    @category_children = Category.roots
    @category = @category_children
    #index
    #@category_children = @categories
    
#    @ancestor_ids = (params[:ancestor_ids] ? params[:ancestor_ids] : 0) # OPTIMIZE
    render :partial => 'categories'
  end
  
  def expand_category
    @category = Category.find(params[:id]) #if params[:id]
    @category_children = @category.children

    index

    render :update do |page|
      page.replace_html "category_children_#{@ancestor_ids}", :partial => 'categories'
      
      page << "elem = $('categories');"
      page << "if (elem) {"
      page.replace_html "categories", :partial => 'categories_and_models'
      page << "}"
    end
  end  

  def search
    if request.post?
      if params[:source_controller].include?("backend/") #current_inventory_pool
        # Backend
        @search_result = current_inventory_pool.models.find_by_contents("*" + params[:search] + "*")
      else
        # Frontend
        @search_result = current_user.models.find_by_contents("*" + params[:search] + "*", :multi => [Package, Template])
      end
    end

    # TODO @categories = Category.roots
    
    render  :layout => $modal_layout_path
  end  
  
  def details
    @model = Model.find(params[:id]) if params[:id]
    render :partial => 'details' #, :layout => $modal_layout_path
  end

  # TODO render_component (solve forgery)
  #def recent
  #end
end
