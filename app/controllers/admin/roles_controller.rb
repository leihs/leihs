class Admin::RolesController < Admin::AdminController

  def index
    unless params[:query].blank?
      @roles = Role.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @roles = Role.paginate :page => params[:page], :per_page => $per_page      
    end
  end
  
  
end
