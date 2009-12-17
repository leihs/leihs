class Admin::AdminController < ApplicationController
  require_role "admin"

  $theme = '00-patterns'
  $modal_layout_path = 'layouts/admin/' + $theme + '/modal'
  $empty_layout_path = 'layouts/admin/' + $theme + '/empty'
  $general_layout_path = 'layouts/admin/' + $theme + '/general'
  $layout_public_path = '/layouts/' + $theme
  
  layout $general_layout_path
    
end
