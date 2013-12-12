class Manage::AccessRightsController <  Manage::ApplicationController

  def index
    @access_rights = if params[:user_ids]
                       if current_inventory_pool
                         current_inventory_pool.access_rights.active
                       elsif is_admin?
                         AccessRight
                       end.where(user_id: params[:user_ids])
                     else
                       raise "User ids required"
                     end
  end

end
