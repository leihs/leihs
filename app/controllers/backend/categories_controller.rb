class Backend::CategoriesController < Backend::BackendController

  before_filter do
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) if not params[:id].blank? and params[:id].to_i != 0 
    @parent = Category.find(params[:parent_id]) unless params[:parent_id].blank?

    @model = current_inventory_pool.models.find(params[:model_id]) unless params[:model_id].blank?
  end

######################################################################

  def index
    # OPTIMIZE 0501 
    params[:sort] ||= 'name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    @categories = if @category
      # TODO 12** optimize filter
      ids = if request.env['REQUEST_URI'].include?("parents")
        @category.parent_ids
      else #if request.env['REQUEST_URI'].include?("children")
        @category.child_ids
      end
      Category.search(params[:query]).
                paginate(:page => params[:page], :per_page => PER_PAGE).
                order("#{params[:sort]} #{params[:sort_mode]}").
                where(:id => ids)
    else
      @show_categories_tree = params[:source_path].blank?
      if request.format == :ext_json # TODO remove
        Category.roots
      else
        Category.search(params[:query]).
                  paginate(:page => params[:page], :per_page => PER_PAGE).
                  order("#{params[:sort]} #{params[:sort_mode]}")
      end
    end    

# TODO vertical tree
#    ############ start graph
#    # NOTE config.gem "rgl", :lib => "rgl/adjacency"
#      unless @category
#          edges = []
#          Category.all.each do |p|
#            p.children.each do |c|
#              edges << [p, c] #[p.id, c.id]
#            end
#          end
#         
#          # http://rgl.rubyforge.org/
#          # http://www.graphviz.org/Download_macos.php
#          require 'rgl/adjacency'
#          require 'rgl/dot'
#          dg=RGL::DirectedAdjacencyGraph.new
#          edges.each {|e| dg.add_edge(e[0], e[1]) }
#          @graph = dg.write_to_graphic_file('png', 'public/images/graphs/categories').gsub('public', '') 
#      end
#    ############ stop graph

    respond_to do |format|
      format.html
    end
  end
    
  def show
    ############ start graph
    # NOTE config.gem "rgl", :lib => "rgl/adjacency"
      edges = []
      @category.children.each do |c|
        edges << [@category, c] #[@category.id, c.id]
      end
      @category.parents.each do |p|
        edges << [p, @category] #[p.id, @category.id]
      end
     
      # http://rgl.rubyforge.org/
      # http://www.graphviz.org/Download_macos.php
      require 'rgl/adjacency'
      require 'rgl/dot'
      dg=RGL::DirectedAdjacencyGraph.new
      edges.each {|e| dg.add_edge(e[0], e[1]) }
      @graph = dg.write_to_graphic_file('png', "public/images/graphs/categories_#{@category.id}").gsub('public', '') 
    ############ stop graph
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
  
