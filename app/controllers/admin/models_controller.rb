class Admin::ModelsController < Admin::AdminController

  before_filter :pre_load

  def index
    params[:sort] ||= 'models.name'
    params[:dir] ||= 'ASC'
    find_options = {:order => sanitize_order(params[:sort], params[:dir])}

    @show_categories_tree = !request.xml_http_request?

    if @category
      models = @category.models
      @show_categories_tree = false
    elsif @model
      models = @model.compatibles
    else
      models = Model
    end    

    case params[:filter]
      when "active"
        models = models.active
    end

    @models = models.search(params[:query], {:page => params[:page], :per_page => $per_page}, find_options)

  end

  def show
  end

  def new
    @model = Model.new
    render :action => 'show'
  end

  def create
    @model = Model.new
    update
  end

  def update
    if @model.update_attributes(params[:model])
      redirect_to admin_model_path(@model)
    else
      flash[:error] = _("Couldn't update ")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

  def destroy
    if @model.items.empty?
      @model.destroy
      respond_to do |format|
        format.html { redirect_to admin_models_path }
        format.js {
          render :update do |page|
            page.visual_effect :fade, "model_#{@model.id}" 
          end
        }
      end
    else
      # TODO 0607 ajax delete
      @model.errors.add_to_base _("The model has items")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

#################################################################

  def properties
    if request.post?
        # TODO 0408** Rails 2.3: accepts_nested_attributes_for
        @model.properties.destroy_all
        @model.properties.create(params[:properties])
        flash[:notice] = _("The properties have been updated.")
    end
    # TODO 0408** scope @model.categories
    @properties_set = Model.with_properties.collect{|m| m.properties.collect(&:key)}.uniq
  end
  
#################################################################

  def accessories
  end
  
  def add_accessory
    @model.accessories.create(:name => params[:name])
    redirect_to :action => 'accessories', :id => @model
  end

  def remove_accessory
    @model.accessories.delete(@model.accessories.find(params[:accessory_id]))
    redirect_to :action => 'accessories', :id => @model
  end
  

#################################################################

  def images
    if request.post?
      @image = Image.new(params[:image])
      @image.model = @model
      if @image.save
        flash[:notice] = _("Attachment was successfully created.")
      else
        flash[:notice] = _("Upload error.")
      end
    elsif request.delete?
      @model.images.destroy(params[:image_id])
    end
  end
  
#################################################################

  def categories
    if request.post?
      unless @category.models.include?(@model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink
        @category.models << @model
        flash[:notice] = _("Category successfully assigned")
      else
        flash[:error] = _("The model is already assigned to this category")
      end
      render :nothing => true # TODO render flash
    elsif request.delete?
      @category.models.delete(@model)
      flash[:notice] = _("Category successfully removed")
      render :nothing => true # TODO render flash
    else
      @categories = @model.categories
    end
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:model_id] if params[:model_id]
    @model = Model.find(params[:id]) unless params[:id].blank?
    @category = Category.find(params[:category_id]) unless params[:category_id].blank?

    @tabs = []
    @tabs << :category_admin if @category
    @tabs << :model_admin if @model
  end
  
  
end
