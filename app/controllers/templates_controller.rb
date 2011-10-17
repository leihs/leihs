class TemplatesController < FrontendController

  def index
  end

  def show
    # TODO 12** through User real association
    # template = current_user.templates.find(params[:id])
    template = Template.find(params[:id])
  end

end
