class Manage::ApplicationController < ApplicationController

  layout 'manage'

  before_filter do
    unless logged_in?
      store_location
      error_response = Proc.new { flash[:error] = _('You are not logged in.') ; render nothing: true, status: :unauthorized }
      respond_to do |format|
        format.html { redirect_to login_path }
        format.json &error_response
        format.js &error_response
      end
    end
  end

  before_filter :check_maintenance_mode, except: :maintenance
  before_filter :required_role

  private

  def check_maintenance_mode
    redirect_to manage_maintenance_path(current_inventory_pool) if current_inventory_pool and Setting.disable_manage_section
  end

  def required_role
    required_manager_role
  end

  # NOTE this method may be overridden in the sub controllers
  def required_manager_role
    open_actions = [:root]
    if not open_actions.include?(action_name.to_sym) and (request.post? or not request.format.json?)
      require_role :lending_manager, current_inventory_pool
    else
      require_role :group_manager, current_inventory_pool
    end
  end

  public

  def root
    flash.keep

    # start_screen = current_user.start_screen
    # if start_screen
    #   redirect_to current_user.start_screen

    last_ip_id = session[:current_inventory_pool_id] || current_user.latest_inventory_pool_id_before_logout
    ip = current_user.inventory_pools.managed.detect{|x| x.id==last_ip_id} if last_ip_id
    role_for_last_ip = current_user.access_right_for(ip).try :role if ip

    if [:inventory_manager, nil].include?(role_for_last_ip) and current_user.access_rights.active.where(role: :inventory_manager).exists?
      ip ||= current_user.inventory_pools.managed(:inventory_manager).first
      redirect_to manage_inventory_path(ip)
    elsif [:lending_manager, nil].include?(role_for_last_ip) and current_user.access_rights.active.where(role: :lending_manager).exists?
      ip ||= current_user.inventory_pools.managed(:lending_manager).first
      redirect_to manage_daily_view_path(ip)
    elsif [:group_manager, nil].include?(role_for_last_ip) and current_user.access_rights.active.where(role: :group_manager).exists?
      ip ||= current_user.inventory_pools.managed(:group_manager).first
      redirect_to manage_contracts_path(ip, status: [:approved, :submitted, :rejected])
    else
      render nothing: true, status: :bad_request
    end
  end

  def maintenance
  end

###############################################################

  protected

    helper_method :is_owner?, :is_privileged_user?, :is_super_user?, :is_inventory_manager?, :is_lending_manager?, :is_group_manager?

    # TODO: what's happening here? Explain the goal of this method
    # looks like getter function, but is also a setter. Should only return the current inventory pool. Current inventory pool should be set elsewhere.
    def current_inventory_pool
      return @current_inventory_pool if @current_inventory_pool # OPTIMIZE

      return nil if current_user.nil? #fixes http://leihs.hoptoadapp.com/errors/756097 (when a user is not logged in but tries to go to a certain action in an inventory pool (for example when clicking a link in hoptoad)
      @current_inventory_pool ||= InventoryPool.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
      session[:current_inventory_pool_id] = @current_inventory_pool.id if @current_inventory_pool
      return @current_inventory_pool
    end

    ####### Helper Methods #######

    # Allow operations on items. 'user' is *not* a customer!
    def is_privileged_user?
      (is_lending_manager? and is_owner?)
    end
    
    def is_super_user?
      (is_inventory_manager? and is_owner?)
    end
    
    def is_inventory_manager?
      current_user.has_role?(:inventory_manager, current_inventory_pool)
    end
    
    def is_lending_manager?
      current_user.has_role?(:lending_manager, current_inventory_pool)
    end

    def is_group_manager?
      current_user.has_role?(:group_manager, current_inventory_pool)
    end

    def is_owner?
      @item.nil? or (current_inventory_pool.id == @item.owner_id)
    end

end
