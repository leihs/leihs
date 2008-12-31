class Admin::CategoriesController < Admin::AdminController

  before_filter :pre_load

  def index
    if @model
      categories = @model.categories
    elsif @category
      # TODO 12** optimize filter
      if request.env['REQUEST_URI'].include?("parents")
          categories = @category.parents
      elsif request.env['REQUEST_URI'].include?("children")
          categories = @category.children
      end
    else
      categories = Category
    end    
    
    unless params[:query].blank?
      @categories = categories.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @categories = categories.paginate :page => params[:page], :per_page => $per_page      
    end
    
#    ############ start graph
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
  end
  
  def show
#    ############ start graph
#          edges = []
#          @category.children.each do |c|
#            edges << [@category, c] #[@category.id, c.id]
#          end
#          @category.parents.each do |p|
#            edges << [p, @category] #[p.id, @category.id]
#          end
#          
#          # http://rgl.rubyforge.org/
#          # http://www.graphviz.org/Download_macos.php
#          require 'rgl/adjacency'
#          require 'rgl/dot'
#          dg=RGL::DirectedAdjacencyGraph.new
#          edges.each {|e| dg.add_edge(e[0], e[1]) }
#          @graph = dg.write_to_graphic_file('png', "public/images/graphs/categories_#{@category.id}").gsub('public', '')  
#    ############ stop graph
  end

  def new
    @category = Category.new
    render :action => 'show'
  end

  def create
    if @model and @category
      unless @category.models.include?(@model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink
        @category.models << @model
        flash[:notice] = _("Category successfully assigned")
      else
        flash[:error] = _("The model is already assigned to this category")
      end
      redirect_to admin_model_categories_path(@model)
    else
      @category = Category.new
      update
    end
  end

  def update
    if @category.update_attributes(params[:category])
      redirect_to admin_category_path(@category)
    else
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

  def destroy
    if @model and @category
        @category.models.delete(@model)
        flash[:notice] = _("Category successfully removed")
        redirect_to admin_model_categories_path(@model)
    elsif @category and @parent
      @parent.children.delete(@category) #if @parent.children.include?(@category)
      redirect_to admin_category_parents_path(@category)
    else
      if @category.models.empty?
        @category.destroy
        redirect_to admin_categories_path
      else
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
    redirect_to admin_category_parents_path(@category)
  end

#################################################################
  
  private
  
  def pre_load
    params[:id] ||= params[:category_id] if params[:category_id]
    @category = Category.find(params[:id]) if params[:id]
    @model = Model.find(params[:model_id]) if params[:model_id]
    @parent = Category.find(params[:parent_id]) if params[:parent_id] 

    @tabs = []
    @tabs << :model_admin if @model
    @tabs << :category_admin if @category
  end


end
  
