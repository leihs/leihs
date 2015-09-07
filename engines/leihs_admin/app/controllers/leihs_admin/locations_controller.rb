module LeihsAdmin
  class LocationsController < AdminController

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

end
