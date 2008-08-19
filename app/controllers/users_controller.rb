class UsersController < Frontend1Controller

  def timeline
    @timeline_xml = current_user.timeline
    render :text => "", :layout => 'backend/' + $theme + '/modal_timeline'
  end

end
