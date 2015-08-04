class Admin::AccessRightsController <  Admin::ApplicationController

  def index
    @access_rights = if params[:user_ids]
                       AccessRight.where(user_id: params[:user_ids])
                     else
                       raise 'User ids required'
                     end
  end

end
