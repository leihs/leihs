class Backend::GroupsController < Backend::BackendController
  
  before_filter :pre_load

  def index
    @groups = current_inventory_pool.groups.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page}

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@groups) }
      format.auto_complete { render :layout => false }
    end
  end

  def show
  end

  def new
    @group = Group.new
    render :action => 'show'
  end

  def create
    @group = Group.new
    @group.inventory_pool = current_inventory_pool
    update
  end
  
  def update
    @group.update_attributes(params[:group])
    redirect_to :action => 'show', :id => @group
  end

  def destroy
    if params[:user_id]
      @group.users.delete(@group.users.find(params[:user_id])) # OPTIMIZE
      redirect_to :action => 'users'
    else
      @group.destroy
      redirect_to :action => 'show'
    end
  end

#################################################################

  def users 
  end
  
  def add_user(user = params[:user])
    @user = current_inventory_pool.users.find(user[:user_id])
    unless @group.users.include? @user
      @group.users << @user
      @group.save!
    end
    redirect_to :action => 'users'
  end

#################################################################

  private
  
  def pre_load
    params[:group_id] ||= params[:id] if params[:id]
    @group = current_inventory_pool.groups.find(params[:group_id]) if params[:group_id]
    
    @tabs = []
    @tabs << :group_backend if @group
  end
end
