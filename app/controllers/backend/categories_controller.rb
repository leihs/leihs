class Backend::CategoriesController < Backend::BackendController

  before_filter do
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) if not params[:id].blank? and params[:id].to_i != 0 
    @parent = Category.find(params[:parent_id]) unless params[:parent_id].blank?

    @model = current_inventory_pool.models.find(params[:model_id]) unless params[:model_id].blank?
  end

######################################################################

  def index(with = params[:with] || {},
            sort = params[:sort] || 'name',
            sort_mode = (params[:sort_mode] || 'asc').downcase)
    categories = if @category
      @category.children
    else
      Category.roots
    end.order("#{sort} #{sort_mode}")

    respond_to do |format|
      format.html
      format.json {
        render json: view_context.hash_for(categories, with.merge({:name => true, :children => true, :is_used => true}))
      }
    end
  end
    
  def show
    respond_to do |format|
      format.json {
        render json: view_context.hash_for(@category, {:name => true})
      }
    end
  end

  def new
    render :action => 'edit'
  end

  def create
    @category = Category.new
    update
  end

  def edit
  end

  def update
    respond_to do |format|
      format.json {
        model_group_links = params[:category].delete(:model_group_links)
        if @category.update_attributes(params[:category])
          @category.links_as_child.each(&:delete)
          model_group_links.each do |link|
            @category.set_parent_with_label(Category.find(link[:parent_id]), link[:label])
          end
          show
        else
          render :text => @category.errors.full_messages.uniq.join(", "), :status => :bad_request
        end
      }
    end
  end
  
  
  def destroy
    if @category and @parent
      @parent.children.delete(@category) #if @parent.children.include?(@category)
      redirect_to backend_inventory_pool_category_parents_path(current_inventory_pool, @category)
    else
      if @category.models.empty?
        @category.destroy
        respond_to do |format|
          format.json { render :nothing => true, :status => :ok }
          format.html { redirect_to backend_inventory_pool_categories_path(current_inventory_pool) }
        end
      else
        # TODO 0607 ajax delete
        @category.errors.add(:base, _("The Category must be empty"))
        render :action => 'show' # TODO 24** redirect to the correct tabbed form
      end
    end
  end

#################################################################
  
  def add_parent(parent = params[:parent])
    begin
      @parent = Category.find(parent[:category_id])
      @category.set_parent_with_label(@parent, parent[:label])
    rescue
      flash[:error] = _("Attempt to add node to own graph collection")
    end
    redirect_to backend_inventory_pool_category_parents_path(current_inventory_pool, @category)
  end
  
end
  
