class Manage::LocationsController < Manage::ApplicationController

  def index
    @locations = Location.filter(params)
  end

end
  
