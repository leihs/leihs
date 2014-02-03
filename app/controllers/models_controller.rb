class ModelsController < ApplicationController

  before_filter do
    require_role :customer
  end
  
  def image
    if img = Model.find(params[:id]).image(params[:offset])
      redirect_to img
    else
      redirect_to :action => :placeholder
    end
  end

  def image_thumb
    if img = Model.find(params[:id]).image_thumb(params[:offset])
      redirect_to img
    else
      redirect_to :action => :placeholder
    end
  end

  def placeholder
    empty_gif_pixel = "R0lGODlhAQABAIAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==\n"
    send_data Base64.decode64(empty_gif_pixel), :type => "image/gif", :disposition => 'inline'
  end
end
