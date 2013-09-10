class Backend::TemplatesController < Backend::BackendController

  before_filter do
    @template = current_inventory_pool.templates.find(params[:id]) if params[:id]
  end

######################################################################

  def index
    @templates = current_inventory_pool.templates.search(params[:query]).paginate(:page => params[:page], :per_page => PER_PAGE).sort

    @unaccomplishable_templates = @templates.select {|t| not t.accomplishable? }
    flash.now[:error] = _("The highlighted entries are not accomplishable for the intended quantity.") unless @unaccomplishable_templates.empty?

    respond_to do |format|
      format.html
    end
  end

  def show
  end

  def new
    @template = current_inventory_pool.templates.build
  end

  def create
    begin
      template = current_inventory_pool.templates.create! params[:template]
      flash[:notice] = _("%s created successfully") % _("Template")
      redirect_to action: :index
    rescue => e
      flash.now[:error] = e.to_s
      render action: :new
    end
  end
  
  def update
    begin
      @template.update_attributes!(params[:template])
      flash[:notice] = _("%s successfully saved") % _("Template")
      redirect_to action: :index
    rescue => e
      flash[:error] = e.to_s
      redirect_to action: :edit
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        if @template.destroy and @template.destroyed?
          render :json => true, :status => 200
        else
          render :json => false, :status => 500
        end
      end
    end
  end
  
#################################################################

  def models
    
  end
  
  def add_model(model_link = params[:model_link])
    @model = current_inventory_pool.models.find(model_link[:model_id])
    @template.model_links.create(:model => @model, :quantity => model_link[:quantity])
    redirect_to :action => 'models'
  end
  
end
