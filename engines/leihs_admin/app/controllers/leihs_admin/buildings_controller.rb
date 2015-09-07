module LeihsAdmin
  class BuildingsController < AdminController

    before_action only: [:edit, :update, :destroy] do
      @building = Building.find(params[:id])
    end

    def index
      respond_to do |format|
        format.html { @buildings = Building.filter(params) }
      end
    end

    def new
      @building = Building.new
    end

    def create
      @building = Building.create params[:building]
      if @building.persisted?
        flash[:notice] = _('Building successfully created')
        redirect_to action: :index
      else
        flash.now[:error] = @building.errors.full_messages.uniq.join(', ')
        render :new
      end
    end

    def edit
    end

    def update
      if @building.update_attributes params[:building]
        flash[:notice] = _('Building successfully updated')
        redirect_to action: :index
      else
        flash.now[:error] = @building.errors.full_messages.uniq.join(', ')
        render :edit
      end
    end

    def destroy
      begin
        @building.destroy
        flash[:success] = _('%s successfully deleted') % _('Building')
      rescue => e
        flash[:error] = e.to_s
      end
      redirect_to action: :index
    end

  end
end

