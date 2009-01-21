class Admin::ModelsController < Admin::AdminController

  before_filter :pre_load

  def index
    params[:sort] ||= 'models.name'
    params[:dir] ||= 'ASC'

    if @category
      models = @category.models
    elsif @model
      models = @model.compatibles
    else
      models = Model
    end    

    @models = models.search(params[:query], {:page => params[:page], :per_page => $per_page}, {:order => sanitize_order(params[:sort], params[:dir])})

    @show_categories_tree = !request.xml_http_request?
  end

  def show
    @graph = @model.graph 
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
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

  def destroy
    if @model.items.empty?
      @model.destroy
      redirect_to admin_models_path
    else
      @model.errors.add_to_base _("The model has items")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

#################################################################

  def properties
  end
  
  def add_property
    @model.properties.create(:key => params[:key], :value => params[:value])
    redirect_to :action => 'properties', :id => @model
  end

  def remove_property
    @model.properties.delete(@model.properties.find(params[:property_id]))
    redirect_to :action => 'properties', :id => @model
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
    end
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:model_id] if params[:model_id]
    @model = Model.find(params[:id]) if params[:id]
    @category = Category.find(params[:category_id]) if params[:category_id]

    @tabs = []
    @tabs << :category_admin if @category
    @tabs << :model_admin if @model
  end
  
  
end
