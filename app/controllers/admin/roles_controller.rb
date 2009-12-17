class Admin::RolesController < Admin::AdminController

  def index
    @roles = Role.search(params[:query], :page => params[:page], :per_page => $per_page)
  end
  
  
end
