class UsersController < FrontendController

  before_filter :pre_load

  def show
    render :layout => false
  end

########################################################################  

  # TODO 15** optimize routing 
  # TODO 15** symbolic link between backend/contracts/show.rfpdf and document.rfpdf ?? 
  def document(id = params[:id])
    @contract = @user.contracts.find(id)
    respond_to do |format|
      if params[:template] == "value_list"
        format.pdf { send_data(render(:template => 'backend/contracts/value_list', :layout => false), :type => 'application/pdf', :filename => "value_list_#{@contract.id}.pdf") }
      else
        format.pdf { send_data(render(:layout => false), :filename => "contract_#{@contract.id}.pdf", :disposition => 'inline') }
      end
    end
  end


  private
  
  def pre_load
    @user = current_user
  end


end
