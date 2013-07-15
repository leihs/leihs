class Borrow::GroupsController < Borrow::ApplicationController

  def index
    @groups = current_user.groups
  end
end
