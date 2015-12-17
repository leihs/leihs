class Manage::TemplatesController < Manage::ApplicationController

  before_action do
    @template = current_inventory_pool.templates.find(params[:id]) if params[:id]
  end

  ######################################################################

  def index
    if request.format.html?
      @templates = current_inventory_pool.templates
      unless @templates.select { |t| !t.accomplishable? }.empty?
        @unaccomplishable_templates_error = \
          _('The highlighted entries are not accomplishable ' \
            'for the intended quantity.')
      end
    else
      @templates = Template.filter params, current_inventory_pool
      set_pagination_header(@templates)
    end
  end

  def new
    @template = current_inventory_pool.templates.build
  end

  def create
    begin
      # Is the 'template' variable really never used?
      current_inventory_pool.templates.create! params[:template]
      flash[:notice] = _('%s created successfully') % _('Template')
      redirect_to action: :index
    rescue => e
      flash.now[:error] = e.to_s
      render action: :new
    end
  end

  def edit
  end

  def update
    begin
      @template.update_attributes!(params[:template])
      flash[:notice] = _('%s successfully saved') % _('Template')
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
          redirect_to manage_templates_path,
                      notice: _('%s successfully deleted') % _('Template')
        else
          redirect_to manage_templates_path,
                      error: @template.errors.full_messages.uniq.join(', ')
        end
      end
    end
  end

end
