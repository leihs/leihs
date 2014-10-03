class Manage::UsersController < Manage::ApplicationController

  before_filter do
    unless current_inventory_pool
      not_authorized! unless is_admin?
    else
      not_authorized! unless is_group_manager? or is_admin?
    end

    if params[:access_right]
      @ip_id = if params[:access_right][:inventory_pool_id] and is_admin?
                 params[:access_right][:inventory_pool_id]
               else
                 current_inventory_pool.id
               end
    end

    params[:id] ||= params[:user_id] if params[:user_id]
    #@user = current_inventory_pool.users.find(params[:id]) if params[:id]
    @user = User.find(params[:id]) if params[:id]
  end

  private

  # NOTE overriding super controller
  def required_manager_role
    open_actions = [:hand_over]
    if not open_actions.include?(action_name.to_sym) and (request.post? or not request.format.json?)
      require_role :lending_manager, current_inventory_pool
    else
      require_role :group_manager, current_inventory_pool
    end
  end

  public

######################################################################

  def index
    @role = params[:role]
    @users = User.filter params, current_inventory_pool
    set_pagination_header @users unless params[:paginate] == "false"
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def new
    @delegation_type = true if params[:type] == "delegation"
    @user = User.new
    @is_admin = false unless @delegation_type
  end

  def new_in_inventory_pool
    @delegation_type = true if params[:type] == "delegation"
    @user = User.new
    @accessible_roles = get_accessible_roles_for_current_user
    @access_right = @user.access_rights.new inventory_pool_id: current_inventory_pool.id, role: :customer
  end

  def create
    should_be_admin = params[:user].delete(:admin)
    if users = params[:user].delete(:users)
      delegated_user_ids = users.map {|h| h["id"]}
    end
    @user = User.new(params[:user])
    @user.login = params[:db_auth][:login] unless @user.is_delegation

    begin
      User.transaction do
        @user.delegated_user_ids = delegated_user_ids if delegated_user_ids
        @user.save!

        unless @user.is_delegation
          @db_auth = DatabaseAuthentication.create!(params[:db_auth].merge(user: @user))
          @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        end

        @user.access_rights.create!(role: :admin) if should_be_admin == "true"

        respond_to do |format|
          format.html do
            flash[:notice] = _("User created successfully")
            redirect_to manage_users_path
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html do
          flash.now[:error] = e.to_s
          @accessible_roles = get_accessible_roles_for_current_user
          @is_admin = should_be_admin
          @delegation_type = true if params[:user].has_key? :delegator_user_id
          render action: :new
        end
      end
    end
  end

  def create_in_inventory_pool
    groups = params[:user].delete(:groups) if params[:user].has_key?(:groups)
    if users = params[:user].delete(:users)
      delegated_user_ids = users.map {|h| h["id"]}
    end

    @user = User.new(params[:user])
    @user.login = params[:db_auth][:login] if params.has_key?(:db_auth)
    @user.groups = groups.map {|g| Group.find g["id"]} if groups

    begin
      User.transaction do
        @user.delegated_user_ids = delegated_user_ids if delegated_user_ids
        @user.save!

        unless @user.is_delegation
          DatabaseAuthentication.create!(params[:db_auth].merge(user: @user))
          @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        end

        unless params[:access_right][:role].to_sym == :no_access
          ar = @user.access_right_for(@current_inventory_pool) || @user.access_rights.build(inventory_pool: @current_inventory_pool)
          ar.update_attributes! role: params[:access_right][:role]
        end

        respond_to do |format|
          format.html do
            flash[:notice] = _("User created successfully")
            redirect_to manage_inventory_pool_users_path(@current_inventory_pool)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html do
          flash.now[:error] = e.to_s
          @accessible_roles = get_accessible_roles_for_current_user
          @delegation_type = true if params[:user].has_key? :delegator_user_id
          render action: :new_in_inventory_pool
        end
      end
    end
  end

  def edit
    @is_admin = @user.has_role? :admin
    @db_auth = DatabaseAuthentication.find_by_user_id(@user.id)
  end

  def edit_in_inventory_pool
    @delegation_type = @user.is_delegation
    @accessible_roles = get_accessible_roles_for_current_user
    @db_auth = DatabaseAuthentication.find_by_user_id(@user.id)
    @access_right = @user.access_right_for current_inventory_pool
  end

  def update
    should_be_admin = params[:user].delete(:admin)

    delegated_user_ids = get_delegated_users_ids params

    begin
      User.transaction do
        params[:user].merge!(login: params[:db_auth][:login]) if params[:db_auth]
        @user.delegated_user_ids = delegated_user_ids if delegated_user_ids
        @user.update_attributes! params[:user]
        if params[:db_auth]
          DatabaseAuthentication.find_by_user_id(@user.id).update_attributes! params[:db_auth].merge(user: @user)
          @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        end
        @user.access_rights.where(role: :admin).each(&:destroy)
        @user.access_rights.create!(role: :admin) if should_be_admin == "true"

        respond_to do |format|
          format.html do
            flash[:notice] = _("User details were updated successfully.")
            redirect_to manage_users_path
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html do
          flash.now[:error] = e.to_s
          @is_admin = should_be_admin
          @db_auth = DatabaseAuthentication.find_by_user_id(@user.id)
          render action: :edit
        end
      end
    end
  end

  def update_in_inventory_pool

    if params[:user]

      if params[:user].has_key?(:groups) and (groups = params[:user].delete(:groups))
        @user.groups = groups.map {|g| Group.find g["id"]}
      end

      delegated_user_ids = get_delegated_users_ids params
    end

    begin
      User.transaction do
        params[:user].merge!(login: params[:db_auth][:login]) if params[:db_auth]
        @user.delegated_user_ids = delegated_user_ids if delegated_user_ids
        @user.update_attributes! params[:user]
        if params[:db_auth]
          DatabaseAuthentication.find_or_create_by(user_id: @user.id).update_attributes! params[:db_auth].merge(user: @user)
          @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        end
        @access_right = AccessRight.find_or_initialize_by(user_id: @user.id, inventory_pool_id: @ip_id)
        @access_right.update_attributes! params[:access_right] unless @access_right.new_record? and params[:access_right][:role].to_sym == :no_access

        respond_to do |format|
          format.html do
            flash[:notice] = _("User details were updated successfully.")
            redirect_to manage_inventory_pool_users_path
          end
          format.json do
            render :text => _("User details were updated successfully.")
          end
        end
      end
    rescue => e
      respond_to do |format|
        format.html do
          flash[:error] = e.to_s
          redirect_to :back
        end
        format.json { render :text => e.to_s, :status => 500 }
      end
    end
  end

  def destroy
    not_authorized! unless is_admin?
    @user.destroy if @user.deletable?
    respond_to do |format|
      format.json{ @user.persisted? ? render(status: :bad_request) : render(status: :no_content)}
      format.html do 
        if @user.persisted? 
          redirect_to(:back, flash: {error: _("You cannot delete this user")})
        else 
          redirect_to(:back, flash: {success: _("%s successfully deleted") % _("User")})
        end 
      end
    end
  end

#################################################################

  def set_start_screen(path = params[:path])
    if current_user.start_screen(path)
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :bad_request
    end
  end

#################################################################

  def extended_info
  end

  def groups
  end

  def add_group(group = params[:group])
    @group = current_inventory_pool.groups.find(group[:group_id])
    unless @user.groups.include? @group
      @user.groups << @group
      @user.save!
    end
    redirect_to :action => 'groups'
  end

  def remove_group(group_id = params[:group_id])
    @group = current_inventory_pool.groups.find(group_id)
    if @user.groups.include? @group
      @user.groups.delete @group
      @user.save!
    end
    redirect_to :action => 'groups'
  end

  def get_accessible_roles_for_current_user
    accessible_roles = [[_("No access"), :no_access], [_("Customer"), :customer]]
    unless @delegation_type
      accessible_roles +=
        if @current_user.has_role? :admin or @current_user.has_role? :inventory_manager, @current_inventory_pool
          [[_("Group manager"), :group_manager], [_("Lending manager"), :lending_manager], [_("Inventory manager"), :inventory_manager]]
      elsif @current_user.has_role? :lending_manager, @current_inventory_pool
        [[_("Group manager"), :group_manager], [_("Lending manager"), :lending_manager]]
      else [] end
    end
    accessible_roles
  end

  def hand_over
    set_shared_visit_variables 0 do
      @contract = @user.get_approved_contract(current_inventory_pool)
      @lines = @contract.lines.includes([:purpose, :model])
      @models = @contract.models.where(type: :Model)
      @software = @contract.models.where(type: :Software)
      @options = @contract.options  
      @items = @contract.items.items
      @licenses = @contract.items.licenses
    end
    @start_date, @end_date = @grouped_lines.keys.sort.first || [Date.today, Date.today]
    add_visitor(@user)
  end

  def take_back
    set_shared_visit_variables 1 do
      @contracts = @user.contracts.signed.where(:inventory_pool_id => current_inventory_pool)
      @lines = @user.contract_lines.to_take_back.where(:contract_id => @contracts).includes([:purpose, :model, :item])
      @models = @contracts.flat_map(&:models).uniq
      @options = @contracts.flat_map(&:options).uniq
      @items = @contracts.flat_map(&:items).uniq
    end
    @start_date = @lines.map(&:start_date).min || Date.today
    @end_date = @lines.map(&:end_date).max || Date.today
    add_visitor(@user)
  end

  private

  def set_shared_visit_variables(date_index)
    @user = User.find(params[:id]) if params[:id]
    @group_ids = @user.group_ids
    yield
    @grouped_lines = @lines.group_by{|g| [g.start_date, g.end_date]}
    @grouped_lines.each_pair do |k,lines|
      @grouped_lines[k] = lines.sort_by{|line| [line.model.name, line.id]}
    end
    @count_today = @grouped_lines.keys.select{|range| range[date_index] == Date.today}.length
    @count_future = @grouped_lines.keys.select{|range| range[date_index] > Date.today}.length
    @count_overdue = @grouped_lines.keys.select{|range| range[date_index] < Date.today}.length
    @purposes = @lines.map(&:purpose).uniq
    @grouped_lines_by_date = []
    @grouped_lines.each_pair do |range, lines|
      @grouped_lines_by_date.push({:date => range[date_index], :grouped_lines => {range => lines}})
    end
    @grouped_lines_by_date = @grouped_lines_by_date.sort_by{|g| g[:date]}
  end

  def get_delegated_users_ids params
    # for complete users replacement, get only user ids without the _destroy flag
    if users = params[:user].delete(:users)
      users.select{|h| h["_destroy"] != "1"}.map {|h| h["id"]}
    end
  end

end
