class Backend::SearchController < ApplicationController

  # TODO refactor and delete this controller


  def model
    if request.post?
      @search_result = Model.find_by_contents("*" + params[:text] + "*")
    end
    render  :layout => $modal_layout_path
  end



  def user
    if request.post?
      @search_result = User.find_by_contents("*" + params[:text] + "*")
    end
    render  :layout => $modal_layout_path
  end


end
