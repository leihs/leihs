class FrontendController < ApplicationController

  # the before_filter needs to be declared *after* require_role, since
  # the current_inventory_pools() calls current_user which is defined in
  # require_role
  require_role "customer"
  before_filter :current_inventory_pools 


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
    ips.compact! # it's possible that we get [nil] when no inventory pools are selected
    conditions = ips.blank? ? {} : {:conditions => ["inventory_pools.id NOT IN (?)", ips]}
    self.excluded_inventory_pool_ids = current_user.active_inventory_pools.all( conditions).collect(&:id)
    render :nothing => true
  end

########################################################################  
  
  protected
  
  # Accesses the current inventory pools from the session.
  def current_inventory_pools
    conditions = {}
    unless session[:excluded_inventory_pool_ids].blank?
      conditions = {:conditions => ["inventory_pools.id NOT IN (?)", session[:excluded_inventory_pool_ids]] }
    end
    @current_inventory_pools ||= current_user.active_inventory_pools.all conditions
  end

  # Stores the given inventory pool ids in the session.
  def excluded_inventory_pool_ids=(ips)
    session[:excluded_inventory_pool_ids] = ips
  end  

end
