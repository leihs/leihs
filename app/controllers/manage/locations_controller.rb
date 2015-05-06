class Manage::LocationsController < Manage::ApplicationController

  def index
    @locations = Location.filter(params)
  end

  def destroy
    location = Location.find params[:id]
    if location.items.empty?
      location.destroy
      flash[:notice] = _('Deleted')
    else
      flash[:error] = _('Error')
    end
    redirect_to :back
  end

end
  
