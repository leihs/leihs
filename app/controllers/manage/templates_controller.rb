class Manage::TemplatesController < Manage::ApplicationController

  before_filter do
    @template = current_inventory_pool.templates.find(params[:id]) if params[:id]
  end

######################################################################

  def index
    if request.format.html?
      @templates = current_inventory_pool.templates
      @unaccomplishable_templates_error = _("The highlighted entries are not accomplishable for the intended quantity.") unless @templates.select{|t| !t.accomplishable?}.empty?
    else
      @templates = Template.filter params, current_inventory_pool
      set_pagination_header(@templates)
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
      format.html do
        if @template.destroy and @template.destroyed?
          redirect_to manage_templates_path, notice: _("%s successfully deleted") % _("Template")
        else
          redirect_to manage_templates_path, error: @template.errors.full_messages.uniq.join(", ")
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
