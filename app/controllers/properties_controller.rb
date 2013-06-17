class PropertiesController < ApplicationController

  def index
    @properties = Property.where(model_id: params[:model_ids])
  end

end
