class Admin::InventoryPoolsController < Admin::AdminController

  before_filter :pre_load

  active_scaffold :inventory_pool do |config|
    config.columns = [:name, :description, :locations] # , :managers
    config.columns.each { |c| c.collapsed = true }

    config.update.link.inline = false

    config.show.columns << :managers
  end
  
#################################################################


  # TODO
  def new
    @inventory_pool = InventoryPool.create # TODO validation
    render :action => 'edit', :layout => false
  end
    
  # TODO
  def edit 
  end
  
  # TODO
  def update
    @inventory_pool.name = params[:name]
    @inventory_pool.description = params[:description]
    @inventory_pool.save
    render :action => 'edit'
  end

#################################################################

  def locations
  end

  def add_location
    @inventory_pool.locations << Location.create(:building => params[:building],
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

  def search_manager
    @users = User.find_by_contents("*" + params[:query] + "*")
    render :partial => 'user_for_manager', :collection => @users
  end

  def add_manager
    role = Role.first(:conditions => {:name => "manager"})
    begin
      @inventory_pool.access_rights << AccessRight.create(:user_id => params[:manager_id], :role_id => role.id)
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
