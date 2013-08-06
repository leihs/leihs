class Backend::TemplatesController < Backend::BackendController

  before_filter do
    params[:template_id] ||= params[:id] if params[:id]
    # NOTE @template is a reserved variable
    @my_template = current_inventory_pool.templates.find(params[:template_id]) if params[:template_id]
  end

######################################################################

  def index
    @templates = current_inventory_pool.templates.search(params[:query]).paginate(:page => params[:page], :per_page => Setting::PER_PAGE)

    respond_to do |format|
      format.html
    end
  end

  def show
  end

  def new
    @my_template = Template.new
    render :action => 'show'
  end

  def create
    @my_template = Template.new
    @my_template.inventory_pools << current_inventory_pool
    update
  end
  
  def update
    @my_template.update_attributes(params[:template])
    redirect_to :action => 'show', :id => @my_template
  end

  def destroy
    if params[:model_link_id]
      @my_template.model_links.delete(@my_template.model_links.find(params[:model_link_id])) # OPTIMIZE
      redirect_to :action => 'models'
    else
      @my_template.destroy
      redirect_to :action => 'show'
    end
  end
  
#################################################################

  def models
    
  end
  
  def add_model(model_link = params[:model_link])
    @model = current_inventory_pool.models.find(model_link[:model_id])
    @my_template.model_links.create(:model => @model, :quantity => model_link[:quantity])
    redirect_to :action => 'models'
  end
  
end
