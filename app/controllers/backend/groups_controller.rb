class Backend::GroupsController < Backend::BackendController
  
  before_filter do
    params[:group_id] ||= params[:id] if params[:id]
    @group = current_inventory_pool.groups.find(params[:group_id]) if params[:group_id]
  end

######################################################################

  def index
    @groups = current_inventory_pool.groups.order(:name)
    @groups = @groups.search(params[:query]) if params[:query]
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @group = Group.new :name => params[:group][:name]
    @group.inventory_pool = current_inventory_pool
    update_users(@group, params[:group].delete(:users)) if params[:group].has_key?(:users)
    if @group.save and @group.update_attributes(params[:group])
      redirect_to backend_inventory_pool_groups_path, :flash => {:notice => _("%s created") % _("Group")}
    else
      render :text => @group.errors.full_messages.uniq.join(", "), :status => :bad_request
    end
  end
  
  def update
    update_users(@group, params[:group].delete(:users)) if params[:group].has_key?(:users)
    if @group.update_attributes(params[:group])
      redirect_to backend_inventory_pool_groups_path, :flash => {:notice => _("%s saved") % _("Group")}
    else
      render :text => @group.errors.full_messages.uniq.join(", "), :status => :bad_request
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        begin @group.destroy
          render :json => true, status: :ok
        rescue ActiveRecord::DeleteRestrictionError => e
          @model.errors.add(:base, e)
          render :text => @group.errors.full_messages.uniq.join(", "), :status => :forbidden
        end
      end
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

  private ####

  def update_users(group, users)
    users.each do |user|
      if user["_destroy"] == "1" or user["_destroy"] == "true"
        group.users.delete User.find(user["id"])
      elsif group.users.find_by_id(user["id"]).nil?
        group.users << User.find(user["id"])
      end
    end
    group.users
  end

end
