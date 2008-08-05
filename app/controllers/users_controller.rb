class UsersController < ApplicationController
  prepend_before_filter :login_required
  

  def timeline
    @timeline_xml = current_user.timeline
    render :text => "", :layout => 'backend/' + $theme + '/modal_timeline'
  end

end
