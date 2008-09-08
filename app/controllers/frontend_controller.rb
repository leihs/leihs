class FrontendController < ApplicationController

  before_filter :current_inventory_pools

  require_role "student"

  layout 'frontend'

  def get_inventory_pools
    ips = current_user.inventory_pools
    c = ips.size
    respond_to do |format|
      format.ext_json { render :json => ips.to_ext_json(:count => c,
                                                        :except => [:description,
                                                                    :logo_url,
                                                                    :contract_url,
                                                                    :contract_description]) }
    end
  end

  def set_inventory_pools(ips = params[:inventory_pool_ids].split(','))
    self.current_inventory_pools = current_user.inventory_pools.all(:conditions => ["inventory_pools.id IN (?)", ips])
    render :nothing => true
  end
  
  
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
