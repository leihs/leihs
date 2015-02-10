class Manage::CategoriesController < Manage::ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json {
        @categories = Category.filter params, current_inventory_pool
        if not params[:include] or not params[:include][:is_used]
          cat = Category.new(name: "* %s *" % _("Not categorized"))
          cat.id = -1
          @categories << cat
        end
        @include_information = params[:include].keys if params[:include]
      }
    end
  end

  def new
    @category ||= Category.new
  end

  def create
    @category = Category.new
    update_category
  end

  def edit
    @category ||= Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    update_category
  end
  
  def destroy
    @category = Category.find(params[:id])
    @parent = Category.find(params[:parent_id]) unless params[:parent_id].blank?
    if @category and @parent
      @parent.children.delete(@category) #if @parent.children.include?(@category)
      redirect_to manage_inventory_pool_category_parents_path(current_inventory_pool, @category)
    else
      if @category.models.empty?
        @category.destroy
        respond_to do |format|
          format.json { render :nothing => true, :status => :ok }
          format.html { redirect_to manage_categories_path(current_inventory_pool), notice: _("%s successfully deleted") % _("Category") }
        end
      else
        # TODO 0607 ajax delete
        @category.errors.add(:base, _("The Category must be empty"))
        render :action => 'show' # TODO 24** redirect to the correct tabbed form
      end
    end
  end

  def upload
    @category = Category.find params[:id]
    params[:files].each do |file|
      if params[:type] == "image"
        image = @category.images.build(:file => file, :filename => file.original_filename)
        unless image.save
          render status: :bad_request, text: image.errors.full_messages.uniq.join(", ") and return
        end
      end
    end
    render status: :no_content, nothing: true
  end

  private

  def update_category
    links = params[:category].delete(:links)
    if @category.update_attributes(params[:category]) and @category.save!
      manage_links @category, links
      render :status => :ok, :json => {id: @category.id}
    else
      render :status => :bad_request, :text => @model.errors.full_messages.uniq.join(", ")
    end
  end

  def manage_links category, links
    return true if links.blank?
    links.each do |link|
      parent = @category.parents.find_by_id(link[1]["parent_id"])
      if parent # parent exists already
        existing_link = ModelGroupLink.find_edge(parent, @category)
        if link[1]["_destroy"] == "1"
          existing_link.destroy
        else
          existing_link.update_attribute :label, link[1]["label"] 
        end
      else
        parent = Category.find link[1]["parent_id"]
        category.set_parent_with_label parent, link[1]["label"]
      end
    end
  end
  
end
  
