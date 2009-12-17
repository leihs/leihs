class UsersController < FrontendController

  before_filter :pre_load

  def show
    render :layout => false
  end

  def account
    render :layout => false
  end

########################################################################  

  def visits
    @visits = @user.visits
    respond_to do |format|
      format.ext_json { render :json => @visits.to_ext_json(:except => [:end, :isDuration],
                                                            :include => {
                                                                :inventory_pool => { :except => [:description,
                                                                                                  :logo_url,
                                                                                                  :contract_url,
                                                                                                  :contract_description,
                                                                                                  :created_at,
                                                                                                  :updated_at] },
                                                                :contract_lines => {
                                                                    :except => [:created_at,
                                                                                :updated_at],
                                                                    :include => { :model => { :except => [:maintenance_period,
                                                                                                          :created_at,
                                                                                                          :updated_at] },
                                                                                  :item => { :except => [:is_borrowable,
                                                                                                         :is_incomplete,
                                                                                                         :is_broken,
                                                                                                         :required_level,
                                                                                                         :created_at,
                                                                                                         :updated_at] } } 
                                                                }
                                                            }
                                                           ) }
    end
  end


  def timeline
    @timeline_xml = @user.timeline
    render :nothing => true, :layout => '/layouts/backend/' + $theme + '/modal_timeline'
  end

  def timeline_visits
    @timeline_xml = @user.timeline_visits
    render :nothing => true, :layout => '/layouts/backend/' + $theme + '/modal_timeline'
  end


########################################################################  

  # TODO 15** optimize routing 
  # TODO 15** symbolic link between backend/contracts/show.rfpdf and document.rfpdf ?? 
  def document(id = params[:id])
    @contract = @user.contracts.find(id)
    respond_to do |format|
      format.pdf { send_data(render(:layout => false), :filename => "contract_#{@contract.id}.pdf", :disposition => 'inline') }
    end
  end


  private
  
  def pre_load
    @user = current_user
  end


end
