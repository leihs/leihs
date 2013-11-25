class Manage::CategoriesController < Manage::ApplicationController

  def index
    @categories = Category.filter params, current_inventory_pool 
    @include_information = params[:include].keys if params[:include]
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

  private

  def update_category
    links = params[:category].delete(:links)
    if @category.update_attributes(params[:category]) and @category.save!
      manage_links @category, links
      redirect_to manage_categories_path(current_inventory_pool), flash: {success: _("Category saved")}
    else
      flash[:error] = @option.errors.full_messages.uniq.join(", ")
      render :new
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
  
