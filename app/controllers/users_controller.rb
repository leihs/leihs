class UsersController < Frontend1Controller

  def timeline
    @timeline_xml = current_user.timeline
    render :nothing => true, :layout => '/layouts/backend/' + $theme + '/modal_timeline'
  end

end
