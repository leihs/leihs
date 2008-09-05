class Backend::UsersController < Backend::BackendController
  active_scaffold :user do |config|
    config.columns = [:login, :access_rights, :inventory_pools, :orders, :contracts]
    config.columns.each { |c| c.collapsed = true }

    config.actions.exclude :create, :update, :delete
    config.action_links.add 'remind', :label => 'Remind', :type => :record
    config.action_links.add 'new_contract', :label => 'New Contract', :type => :record, :page => true
  end

  # filter for active_scaffold
  def conditions_for_collection
    ['access_rights.inventory_pool_id = ?', current_inventory_pool.id] 
  end

#################################################################
  def managers
    render :inline => "Managers <hr /> <%= render :active_scaffold => 'backend/users', :conditions => ['users.id IN (?)', (@current_inventory_pool.users & User.managers)] %>", # TODO optimize conditions
           :layout => $general_layout_path        
  end
  
  def students
    render :inline => "Students <hr /> <%= render :active_scaffold => 'backend/users', :conditions => ['users.id IN (?)', (@current_inventory_pool.users & User.students)] %>", # TODO optimize conditions
           :layout => $general_layout_path        
  end

#################################################################

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
