class Backend::SearchController < ApplicationController

  def model
    if request.post?
      @search_result = Model.find(:all, :conditions => {:name => params[:text]})
    end
  end
end
