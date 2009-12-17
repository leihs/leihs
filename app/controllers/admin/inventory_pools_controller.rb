class Admin::InventoryPoolsController < Admin::AdminController

  before_filter :pre_load

  def index
    params[:sort] ||= 'inventory_pools.name'
    params[:dir] ||= 'ASC'
    @inventory_pools = InventoryPool.search(params[:query], { :page => params[:page], :per_page => $per_page }, { :order => sanitize_order(params[:sort], params[:dir]) })
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
      respond_to do |format|
        format.html { redirect_to admin_inventory_pools_path }
        format.js {
          render :update do |page|
            page.visual_effect :fade, "inventory_pool_#{@inventory_pool.id}" 
          end
        }
      end
    else
      # TODO 0607 ajax delete
      @inventory_pool.errors.add_to_base _("The Inventory Pool must be empty")
      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

#################################################################

  def managers
  end

  def add_manager
    role = Role.first(:conditions => {:name => "lending manager"})
    begin
      @inventory_pool.access_rights.create(:user_id => params[:inventory_pool][:manager_id], :role_id => role.id)
    rescue
      # unique index, record already present
    end
    redirect_to :action => 'managers', :id => @inventory_pool
  end

  def remove_manager
    role = Role.first(:conditions => {:name => "lending manager"})
    @inventory_pool.access_rights.delete(@inventory_pool.access_rights.first(:conditions => { :user_id => params[:manager_id], :role_id => role.id }))
    redirect_to :action => 'managers', :id => @inventory_pool
  end
  
#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:inventory_pool_id] if params[:inventory_pool_id]
    @inventory_pool = InventoryPool.find(params[:id]) if params[:id]

    @tabs = []
    @tabs << :inventory_pool_admin if @inventory_pool
  end

  
end
