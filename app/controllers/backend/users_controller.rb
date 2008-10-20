class Backend::UsersController < Backend::BackendController


  def index
    users = current_inventory_pool.users
    
    unless params[:query].blank?
      users = users.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    end
    
    # TODO *17* search and filter
    case params[:filter]
      when "managers"
        users = users & User.managers # TODO optimize conditions
      when "students"
        users = users & User.students # TODO optimize conditions
    end

    # TODO *17* you're paginating a second time!!!
    @users = users.paginate :page => params[:page], :per_page => $per_page      
  end

  def details
    @user = current_inventory_pool.users.find(params[:id])
    render :layout => $modal_layout_path
  end

  def search
    @search_result = current_inventory_pool.users.find_by_contents("*" + params[:query] + "*") if request.post?
    render  :layout => $modal_layout_path
  end  

  def remind
    @user = current_inventory_pool.users.find(params[:id])
    render :text => @user.remind(current_user) # TODO    
  end
  
  def new_contract
    redirect_to :controller => 'hand_over', :action => 'show', :user_id => params[:id]
  end
  
end
