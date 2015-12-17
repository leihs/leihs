class Manage::BuildingsController < Manage::ApplicationController

  before_action only: [:edit, :update, :destroy] do
    @building = Building.find(params[:id])
  end

  def index
    @buildings = current_inventory_pool.buildings.filter(params)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def edit
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
