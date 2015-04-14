class Manage::ApplicationController < ApplicationController

  layout 'manage'

  before_filter do
    unless logged_in?
      store_location
      error_response = Proc.new { flash[:error] = _("You are not logged in.") ; render :nothing => true, :status => :unauthorized }
      respond_to do |format|
        format.html { redirect_to login_path and return }
        format.json &error_response
        format.js &error_response
      end
    end
  end

  before_filter :check_maintenance_mode, except: :maintenance
  before_filter :required_role

  private

  def check_maintenance_mode
    redirect_to manage_maintenance_path if current_inventory_pool and Setting::DISABLE_MANAGE_SECTION
  end

  def required_role
    unless is_admin?
      required_manager_role
    end
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
    # start_screen = current_user.start_screen
    # if start_screen
    #   redirect_to current_user.start_screen, flash: flash

    if current_user.has_role? :admin
      if current_inventory_pool
        redirect_to manage_edit_inventory_pool_path(current_inventory_pool), flash: flash
      else
        redirect_to manage_inventory_pools_path, flash: flash
      end
    else
      last_ip_id = session[:current_inventory_pool_id] || current_user.latest_inventory_pool_id_before_logout
      ip = current_user.inventory_pools.managed.detect{|x| x.id==last_ip_id} if last_ip_id
      role_for_last_ip = current_user.access_right_for(ip).try :role if ip

      if [:inventory_manager, nil].include?(role_for_last_ip) and current_user.access_rights.active.where(role: :inventory_manager).exists?
        ip ||= current_user.inventory_pools.managed(:inventory_manager).first
        redirect_to manage_inventory_path(ip), flash: flash
      elsif [:lending_manager, nil].include?(role_for_last_ip) and current_user.access_rights.active.where(role: :lending_manager).exists?
        ip ||= current_user.inventory_pools.managed(:lending_manager).first
        redirect_to manage_daily_view_path(ip), flash: flash
      elsif [:group_manager, nil].include?(role_for_last_ip) and current_user.access_rights.active.where(role: :group_manager).exists?
        ip ||= current_user.inventory_pools.managed(:group_manager).first
        redirect_to manage_contracts_path(ip, status: [:approved, :submitted, :rejected]), flash: flash
      else
        render :nothing => true, :status => :bad_request
      end
    end
  end

  def maintenance
  end

###############################################################  

  # swap model for a given line
  def generic_swap_model_line(document)
    if request.post?
      if params[:model_id].nil?
        flash[:notice] = _("Model must be selected")
      else
        document.swap_line(params[:line_id], params[:model_id], current_user.id)
      end
      redirect_to :action => 'show', :id => document.id     
    else
      redirect_to :controller => 'models', 
                  :layout => 'modal',
                  :user_id => document.user_id,
                  :source_path => request.env['REQUEST_URI'],
                  "#{document.class.to_s.underscore}_line_id" => params[:line_id]
    end
  end

###############################################################  

  protected

    helper_method :is_owner?, :is_privileged_user?, :is_super_user?, :is_inventory_manager?, :is_lending_manager?, :is_group_manager?, :current_managed_inventory_pools

    # TODO: what's happening here? Explain the goal of this method
    # looks like getter function, but is also a setter. Should only return the current inventory pool. Current inventory pool should be set elsewhere.
    def current_inventory_pool
      return @current_inventory_pool if @current_inventory_pool # OPTIMIZE

      # TODO 28** patch to Rails: actionpack/lib/action_controller/...
      # i.e. /inventory_pools/123 generates automatically params[:inventory_pools_id] additionaly to params[:id]
      unless ["users", "buildings"].include? controller_name
        params[:inventory_pool_id] ||= params[:id] if params[:id]
      end

      return nil if current_user.nil? #fixes http://leihs.hoptoadapp.com/errors/756097 (when a user is not logged in but tries to go to a certain action in an inventory pool (for example when clicking a link in hoptoad)
      @current_inventory_pool ||= InventoryPool.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
      session[:current_inventory_pool_id] = @current_inventory_pool.id if @current_inventory_pool
      return @current_inventory_pool
    end

    def current_managed_inventory_pools
      @current_managed_inventory_pools ||= (current_user.inventory_pools.managed - [current_inventory_pool]).sort
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
