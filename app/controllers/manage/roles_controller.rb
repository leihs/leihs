class Manage::RolesController < Manage::ApplicationController

  def index
    @roles = Role.all
  end

end
