class Admin::AdminController < ApplicationController
  require_role "admin"

  $theme = '00-patterns'
  $modal_layout_path = 'layouts/admin/' + $theme + '/modal'
  $general_layout_path = 'layouts/admin/' + $theme + '/general'
  $layout_public_path = '/layouts/' + $theme
  
  layout $general_layout_path
  

  protected
  
    # OPTIMIZE **09 (merge with backend)
    def render(args = {})
      default_args = {}
      if params[:layout] == "modal"
        default_args[:layout] = $modal_layout_path
      elsif request.xml_http_request?
        default_args[:layout] = false
      end
      super default_args.merge(args)
    end

  
end
