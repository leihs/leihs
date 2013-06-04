class CategoryLinksController < ApplicationController

  def index
    @links = if params[:ancestor_id]
      ModelGroupLink.where(:ancestor_id => params[:ancestor_id]) 
    else
      ModelGroupLink.all
    end
  end

end