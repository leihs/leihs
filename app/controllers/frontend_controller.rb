class FrontendController < ApplicationController

  before_filter :current_inventory_pools

  require_role "customer"

  layout "frontend"

  def index
    @user = current_user
    @missing_fields = @user.authentication_system.missing_required_fields(@user)
    render :template => "users/show", :layout => "frontend_2010" unless @missing_fields.empty?
  end

  def get_inventory_pools
    ips = current_user.active_inventory_pools
    c = ips.size
    respond_to do |format|
      format.ext_json { render :json => ips.to_ext_json(:class => "InventoryPool",
                                                        :count => c,
                                                        :except => [:description,
                                                                    :logo_url,
                                                                    :contract_url,
                                                                    :contract_description]) }
    end
  end

  def set_inventory_pools(ips = params[:inventory_pool_ids] || [])
    self.current_inventory_pools = current_user.active_inventory_pools.all(:conditions => ["inventory_pools.id IN (?)", ips])
    render :nothing => true
  end

########################################################################  
  
  protected
    
  # Accesses the current inventory pools from the session.
  # Future calls avoid the database because nil is not equal to false.
  def current_inventory_pools
    @current_inventory_pools ||= InventoryPool.all(:conditions => ["id IN (?)", session[:inventory_pool_ids]]) if session[:inventory_pool_ids] and not @current_inventory_pools == false
    @current_inventory_pools ||= (self.current_inventory_pools = current_user.inventory_pools) if current_user
  end

  # Stores the given inventory pool ids in the session.
  def current_inventory_pools=(ips)
    session[:inventory_pool_ids] = ips.collect(&:id)
    @current_inventory_pools = ips || false
  end  

end
