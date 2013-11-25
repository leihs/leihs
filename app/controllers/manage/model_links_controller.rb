class Manage::ModelLinksController < Manage::ApplicationController

  def index
    @model_links = Template.find(params[:template_id]).model_links
  end

end
