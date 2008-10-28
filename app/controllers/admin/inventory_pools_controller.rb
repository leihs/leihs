class Admin::InventoryPoolsController < Admin::AdminController

  before_filter :pre_load


  def index
    inventory_pools = InventoryPool
    
    unless params[:query].blank?
      inventory_pools = inventory_pools.all(:conditions => ["name LIKE ?", "%" + params[:query] + "%"])
    end

    @inventory_pools = inventory_pools.paginate :page => params[:page], :per_page => $per_page
  end

  def show
  end

  def new
    @inventory_pool = InventoryPool.new
    render :action => 'show'
  end

  def create
    @inventory_pool = InventoryPool.new
    update
  end

  def update
    if @inventory_pool.update_attributes(params[:inventory_pool])
      redirect_to admin_inventory_pool_path(@inventory_pool)
    else
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

  def destroy
    if @inventory_pool.items.empty?
      @inventory_pool.destroy
      redirect_to admin_inventory_pools_path
    else
      @inventory_pool.errors.add_to_base _("The Inventory Pool must be empty")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

#################################################################

  def locations
  end

  def add_location
    @inventory_pool.locations.create(:building => params[:building],
                                     :room => params[:room],
                                     :shelf => params[:shelf])
    redirect_to :action => 'locations', :id => @inventory_pool
  end

  def remove_location
    @inventory_pool.locations.delete(@inventory_pool.locations.find(params[:location_id]))
    redirect_to :action => 'locations', :id => @inventory_pool
  end

#################################################################

  def managers
  end

#  def search_manager
#    @users = User.find_by_contents("*" + params[:query] + "*")
#    render :partial => 'user_for_manager', :collection => @users
#  end
 
  def add_manager
    role = Role.first(:conditions => {:name => "manager"})
    begin
      @inventory_pool.access_rights.create(:user_id => params[:inventory_pool][:manager_id], :role_id => role.id)
    rescue
      # unique index, record already present
    end
    redirect_to :action => 'managers', :id => @inventory_pool
  end

  def remove_manager
    role = Role.first(:conditions => {:name => "manager"})
    @inventory_pool.access_rights.delete(@inventory_pool.access_rights.first(:conditions => { :user_id => params[:manager_id], :role_id => role.id }))
    redirect_to :action => 'managers', :id => @inventory_pool
  end
  
#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:inventory_pool_id] if params[:inventory_pool_id]
    @inventory_pool = InventoryPool.find(params[:id]) if params[:id]
  end

  
end
