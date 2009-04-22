class Admin::AdminController < ApplicationController
  require_role "admin"

  $theme = '00-patterns'
  $modal_layout_path = 'layouts/admin/' + $theme + '/modal'
  $general_layout_path = 'layouts/admin/' + $theme + '/general'
  $layout_public_path = '/layouts/' + $theme
  
  layout $general_layout_path


# TODO 1903** custom require_role
#  prepend_before_filter { |c| c.leihs_require_role "admin", :for_current_inventory_pool => true }
#
#  def leihs_require_role(role, options = {})
#    options.assert_valid_keys(
#      :for_current_inventory_pool
#    )    
#    
#    login_required
#    return unless logged_in?
#    
#    current_user.has_role?(role, nil, true)
#  end
    
end
