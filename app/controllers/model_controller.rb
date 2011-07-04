class ModelController < FrontendController

  def index
    # get a single model here
    @user = current_user
  end

end