class ModelsController < ApplicationController

  before_filter do
    require_role "customer"
  end
  
  def image
    redirect_to Model.find(params[:id]).image(params[:offset]), :status => :moved_permanently
  end

  def image_thumb
    redirect_to Model.find(params[:id]).image_thumb(params[:offset]), :status => :moved_permanently
  end
end
