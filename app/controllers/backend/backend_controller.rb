class Backend::BackendController < ApplicationController
  
  before_filter do
    unless logged_in?
      store_location
      redirect_to new_session_path and return
    else
      require_role "manager", current_inventory_pool
    end
  end
  
  layout 'backend'
 
###############################################################  
  
  def index
    # if user is admin only, redirect to admin section (/inventory_pools)
    if current_user.managed_inventory_pools.blank? and current_user.has_role? :admin
      redirect_to backend_inventory_pools_path
    elsif current_user.access_rights.managers.where(:access_level => 3).exists? # user has manager level 3 => inventory manager
      redirect_to backend_inventory_pool_models_path(current_user.managed_inventory_pools.first)
    elsif current_user.access_rights.managers.where(:access_level => 1..2).exists? # user has at least manager level 1 => lending manager
      redirect_to backend_inventory_pool_path(current_user.managed_inventory_pools.first)
    else
      # no one should enter here (customers should already be redirectet by the before filter)     
      redirect_to root_path
    end 
  end
  
###############################################################    
  
  def search(term = params[:term], types = Array(params[:types]))
    
    conditions = { :klasses => {}, :filter => { :inventory_pool_id => [current_inventory_pool.id] } }
    
    # default if types are not provided
    conditions[:klasses][User]      = {:sort_by => "firstname ASC, lastname ASC"} if types.blank? or types.include?("user")
    conditions[:klasses][Order]     = {:sort_by => "created_at DESC"} if types.blank? or types.include?("order")
    conditions[:klasses][Contract]  = {:sort_by => "created_at DESC", :filter => {:status_const => Contract::SIGNED..Contract::CLOSED}} if types.blank? or types.include?("contract")
    conditions[:klasses][Model]     = {:sort_by => "name ASC"} if types.blank? or types.include?("model")
    conditions[:klasses][Item]      = {:sort_by => "inventory_code ASC"} if types.blank? or types.include?("item")
    # no default
    conditions[:klasses][Option]    = {:sort_by => "options.name ASC"} if types.include?("option")
    conditions[:klasses][Template]  = {:sort_by => "model_groups.name ASC"} if types.include?("template")
    
    #TODO conditions << { :filter => { :owner_id => [current_inventory_pool.id]} } if  # INVENTORY MANAGER
    #TODO conditions << { :filter => { :owner_id => [current_inventory_pool.id]} } if  # ADMIN find USERS
    
    # TODO prevent search for Inventory if current_user doesn't have enough permissions
    # TODO implement this later on :filter => { :owner_id => [current_inventory_pool.id]}
    # TODO implement serach for all user "ADMIN" and merge with users
    
    results = []
    @hits = {}
    conditions[:klasses].each_pair do |klass, options|
      r = klass.search2(term).
            filter2(conditions[:filter].merge(options[:filter] || {})).
            order(options[:sort_by]).
            paginate(:page => params[:page], :per_page => $per_page)

      results << r
      @hits[klass.to_s.underscore] = r.total_entries 
    end
    
    respond_to do |format|
      format.html {
        @results = results.flatten
        render :template => "backend/backend/focused_search" if types and types.size == 1
      }
      format.json {
        render :json => view_context.results_json(results.flatten.sort_by(&:name).compact)
      }
    end
  end

###############################################################  

#tmp#
=begin
  def database_backup
    dir = "#{Rails.root}/db/backups"
    timestamp = Time.now.to_formatted_s(:number)
    src = "#{dir}/#{timestamp}.sql"
    File.open(src, 'w') do |f|
      f << ActiveRecord::Base.connection.structure_dump
      f << ActiveRecord::Base.connection.data_dump
    end
    
    flash[:notice] = _("Database backup successfully done.")
    render :update do |page|
      page.replace_html 'flash', flash_content
      flash.discard
    end
  end
=end

   # add a new line
   def generic_add_line(document, start_date = params[:start_date], end_date = params[:end_date])
    if request.post?
      if params[:model_group_id]
        model = ModelGroup.find(params[:model_group_id]) # TODO scope current_inventory_pool ?
      else
        model = current_inventory_pool.models.find(params[:model_id])
      end
      params[:user_id] = current_user.id
      
      model.add_to_document(document, params[:user_id], params[:quantity], start_date, end_date, current_inventory_pool)

      flash[:notice] = document.errors.full_messages unless document.save
      unless @prevent_redirect # TODO 29**
        redirect_to :action => 'show',
                    :id => document.id
      end
    else
      redirect_to :controller => 'models', 
                  :layout => 'modal',
                  :source_path => request.env['REQUEST_URI'],
                  :start_date => start_date,
                  :end_date => end_date,
                  :user_id => document.user_id
    end
  end


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

  # remove OrderLines or ContractLines
  def generic_remove_lines(document)
    if request.delete?
      params[:lines].each {|l| document.remove_line(l, current_user.id) }
      redirect_to :action => 'show', :id => document.id
    else
      @lines = document.lines.find(params[:lines].split(','))
      params[:layout] = "modal"
      render :template => 'backend/backend/remove_lines'
    end   
  end    
###############################################################  

  protected

    helper_method :is_privileged_user?, :is_super_user?, :is_inventory_manager?, :is_lending_manager?, :is_apprentice?, :is_admin?, :current_managed_inventory_pools

    # TODO: what's happening here? Explain the goal of this method
    def current_inventory_pool
      return @current_inventory_pool if @current_inventory_pool # OPTIMIZE
      return nil if controller_name == "inventory_pools" and not ["create", "show", "update"].include?(action_name)
      # TODO 28** patch to Rails: actionpack/lib/action_controller/...
      # i.e. /inventory_pools/123 generates automatically params[:inventory_pools_id] additionaly to params[:id]
      if !params[:inventory_pool_id] and params[:id] and controller_name != "users"
        request.path_parameters[:inventory_pool_id] = params[:id]
        request.parameters[:inventory_pool_id] = params[:id]
      end
      return nil if current_user.nil? #fixes http://leihs.hoptoadapp.com/errors/756097 (when a user is not logged in but tries to go to a certain action in an inventory pool (for example when clicking a link in hoptoad)
      @current_inventory_pool ||= current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
    end

    def current_managed_inventory_pools
      @current_managed_inventory_pools ||= (current_user.managed_inventory_pools - [current_inventory_pool])
    end

    ##################################################
    # ACL
  
    def authorized_admin_user?
      not_authorized! unless is_admin?
    end

    def authorized_privileged_user?
      not_authorized! unless is_privileged_user?
    end
    
    def not_authorized!
        msg = "You don't have appropriate permission to perform this operation."
        respond_to do |format|
          format.html { flash[:error] = msg
                        redirect_to backend_inventory_pools_path
                      } 
          format.json { render :text => msg }
        end
    end
  
    ####### Helper Methods #######

	  def is_admin?
    	#@is_admin ||=
      current_user.has_role?('admin')
  	end

    # Allow operations on items. 'user' is *not* a customer!
    def is_privileged_user?
      #@is_privileged_user ||=
      (current_user.has_at_least_access_level(2, current_inventory_pool) and is_owner?)
    end
    
    def is_super_user?
      #@is_super_user ||=
      (is_inventory_manager? and is_owner?)
    end
    
    def is_inventory_manager?
      #@is_inventory_manager ||=
      current_user.has_at_least_access_level(3, current_inventory_pool)
    end
    
    def is_lending_manager?(inventory_pool = current_inventory_pool)
      #@is_lending_manager ||= []
      #@is_lending_manager[inventory_pool] ||=
      current_user.has_at_least_access_level(2, inventory_pool)
    end
    
    def is_apprentice?(inventory_pool = current_inventory_pool)
      #@is_apprentice ||= []
      #@is_apprentice[inventory_pool] ||=
      current_user.has_at_least_access_level(1, inventory_pool)
    end
    

####################################################  
  
  private
  
  def is_owner?
    @item.nil? or (current_inventory_pool.id == @item.owner_id)
  end
  
end
