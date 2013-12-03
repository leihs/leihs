class Manage::BuildingsController < Manage::ApplicationController

  def index
    @buildings = Building.filter(params)
  end

end
  
