class UsersController < FrontendController

  def timeline
    @timeline_xml = current_user.timeline
    render :nothing => true, :layout => '/layouts/backend/' + $theme + '/modal_timeline'
  end

  def timeline_visits
    @timeline_xml = current_user.timeline_visits
    render :nothing => true, :layout => '/layouts/backend/' + $theme + '/modal_timeline'
  end


########################################################################  

  # TODO
  def show_document(id = params[:id])
    @contract = current_user.contracts.find(id)
    respond_to do |format|
      format.pdf { send_data(render(:layout => false), :filename => "contract_#{@contract.id}.pdf", :disposition => 'inline') }
    end
  end


end
