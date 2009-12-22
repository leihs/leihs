class Backend::CategoriesController < Backend::BackendController

  before_filter :pre_load

  def index
    # OPTIMIZE 0408** sorting 
    params[:sort] ||= 'model_groups.name'
    params[:dir] ||= 'ASC'

    if @category
      # TODO 12** optimize filter
      if request.env['REQUEST_URI'].include?("parents")
          categories = @category.parents
      else #if request.env['REQUEST_URI'].include?("children")
          categories = @category.children
      end
    else
      if request.format == :ext_json
        @categories = Category.roots
      else
        categories = Category
      end
      @show_categories_tree = (!request.xml_http_request? and params[:source_path].blank?)
    end    
    
    @categories ||= categories.search(params[:query], {:page => params[:page], :per_page => $per_page}, {:order => sanitize_order(params[:sort], params[:dir])})

    respond_to do |format|
      format.html
      format.ext_json { id = (@category ? @category.id : 0)
                        render :json => @categories.sort.to_json(:methods => [[:text, id],
                                                                              :leaf,
                                                                              :real_id],
                                                            :except => [:id]) }
      format.auto_complete { render :layout => false }
    end
  end
    
  def show
    @category = Category.find(params[:id])
  end

  def new
    @category = Category.new
    render :action => 'show'
  end

  def create
    @category = Category.new
    update
  end

  def update
    if @category.update_attributes(params[:category])
      redirect_to backend_inventory_pool_category_path(current_inventory_pool, @category)
    else
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
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
          format.html { redirect_to backend_inventory_pool_categories_path(current_inventory_pool) }
          format.js {
            render :update do |page|
              page.visual_effect :fade, "category_#{@category.id}" 
            end
          }
        end
      else
        # TODO 0607 ajax delete
        @category.errors.add_to_base _("The Category must be empty")
        render :action => 'show' # TODO 24** redirect to the correct tabbed form
      end
    end
  end

#################################################################
  
  def add_parent(parent = params[:parent])
    begin
      @parent = Category.find(parent[:category_id])
      @parent.children << @category unless @parent.children.include?(@category)
      @category.set_label(@parent, parent[:label]) unless parent[:label].blank?
    rescue
      flash[:error] = _("Attempt to add node to own graph collection")
    end
    redirect_to backend_inventory_pool_category_parents_path(current_inventory_pool, @category)
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) unless params[:id].blank?
    @parent = Category.find(params[:parent_id]) unless params[:parent_id].blank?

    @model = current_inventory_pool.models.find(params[:model_id]) unless params[:model_id].blank?

    @tabs = []
    @tabs << :model_backend if @model

    @tabs << :category_backend if @category

  end
  
end
  
