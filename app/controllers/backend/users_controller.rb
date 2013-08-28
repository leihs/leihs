class Backend::UsersController < Backend::BackendController

  before_filter do
    unless current_inventory_pool
      not_authorized! unless is_admin?
    else
      not_authorized! unless is_lending_manager? or is_admin?
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

######################################################################

  def index

    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || PER_PAGE).to_i
    search = params[:search]
    @role = params[:role]
    suspended = (params[:suspended] == "true")
    with = params[:with] ? params[:with].deep_symbolize_keys : {}

    respond_to do |format|

      format.html do
        @users = (@role == "admins" ? User.admins : User.scoped).search(search).order("users.firstname ASC").paginate(:page => @page, :per_page => @per_page)
        render template: "backend/users/index_in_inventory_pool" if current_inventory_pool
      end

      format.json {
        users = case @role
                  when "admins"
                    User.admins
                  when "no_access"
                    User.no_access_for(current_inventory_pool)
                  when "customers", "lending_managers", "inventory_managers"
                    current_inventory_pool.send(suspended ? :suspended_users : :users).send(@role)
                  else
                    User.scoped
                end.search(search).order("users.firstname ASC").paginate(:page => @page, :per_page => @per_page)

        render json: {
            entries: view_context.hash_for(users, with.merge({:access_right => true, :preset => :user})),
            pagination: {
                current_page: [users.current_page, users.total_pages].min, # FIXME current_page cannot be greater than total_pages, is this a will_paginate bug ??
                per_page: users.per_page,
                total_pages: users.total_pages,
                total_entries: users.total_entries
            }
        }
      }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json {
        render json: view_context.hash_for(@user, {:access_right => true, :preset => :user, :groups => true, :db_auth => true})
      }
    end
  end

  def new
    @user = User.new
    @is_admin = false
  end

  def new_in_inventory_pool
    @user = User.new
    @accessible_roles = get_accessible_roles_for_current_user
    @access_right = @user.access_rights.new inventory_pool_id: current_inventory_pool.id, role: Role.find_by_name("customer")
  end

  def create

    should_be_admin = params[:user].delete(:admin)
    @user = User.new(params[:user].merge(login: params[:db_auth][:login]))

    begin
      User.transaction do
        @user.save!
        @db_auth = DatabaseAuthentication.create!(params[:db_auth].merge(user: @user))
        @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        @user.all_access_rights.create!(role_name: "admin") if should_be_admin == "true"

        respond_to do |format|
          format.html do
            flash[:notice] = _("User created successfully")
            redirect_to backend_users_path
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html do
          flash.now[:error] = e.to_s
          @accessible_roles = get_accessible_roles_for_current_user
          @is_admin = should_be_admin
          render action: :new
        end
      end
    end
  end

  def create_in_inventory_pool
    groups = params[:user].delete(:groups) if params[:user].has_key?(:groups)
    @user = User.new(params[:user].merge(login: params[:db_auth][:login]))
    @user.groups = groups.map {|g| Group.find g["id"]} if groups

    begin
      User.transaction do
        @user.save!
        DatabaseAuthentication.create!(params[:db_auth].merge(user: @user))
        @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        @user.access_rights.create!(inventory_pool: @current_inventory_pool, role_name: params[:access_right][:role_name]) unless params[:access_right][:role_name] == "no_access"

        respond_to do |format|
          format.html do
            flash[:notice] = _("User created successfully")
            redirect_to backend_inventory_pool_users_path(@current_inventory_pool)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html do
          flash.now[:error] = e.to_s
          @accessible_roles = get_accessible_roles_for_current_user
          render action: :new_in_inventory_pool
        end
      end
    end
  end

  def edit
    @is_admin = @user.has_role? "admin"
    @db_auth = DatabaseAuthentication.find_by_user_id(@user.id)
  end

  def edit_in_inventory_pool
  end

  def update

    should_be_admin = params[:user].delete(:admin)

    if db_auth = params[:db_auth]
      db_auth.delete(:password) if db_auth[:password] == "_password_"
      db_auth.delete(:password_confirmation) if db_auth[:password_confirmation] == "_password_"
      @user.login = db_auth[:login] if db_auth[:login]
    end

    begin
      User.transaction do
        @user.update_attributes! params[:user]
        if db_auth
          DatabaseAuthentication.find_by_user_id(@user.id).update_attributes! db_auth.merge(user: @user)
          @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        end
        @user.all_access_rights.delete_all {|ar| ar.role_name == "admin"}
        @user.all_access_rights.create!(role_name: "admin") if should_be_admin == "true"

        respond_to do |format|
          format.html do
            flash[:notice] = _("User details were updated successfully.")
            redirect_to backend_users_path
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

    if params[:user] and params[:user].has_key?(:groups) and (groups = params[:user].delete(:groups))
      @user.groups = groups.map {|g| Group.find g["id"]}
    end

    if db_auth = params[:db_auth]
      db_auth.delete(:password) if db_auth[:password] == "_password_"
      db_auth.delete(:password_confirmation) if db_auth[:password_confirmation] == "_password_"
      @user.login = db_auth[:login] if db_auth[:login]
    end

    begin
      User.transaction do
        @user.update_attributes! params[:user]

        if db_auth
          DatabaseAuthentication.find_or_create_by_user_id(@user.id).update_attributes! db_auth.merge(user: @user)
          @user.update_attributes!(authentication_system_id: AuthenticationSystem.find_by_class_name(DatabaseAuthentication.name).id)
        end

        @access_right = AccessRight.find_or_initialize_by_user_id_and_inventory_pool_id(@user.id, @ip_id)
        @access_right.update_attributes! params[:access_right] unless @access_right.new_record? and params[:access_right][:role_name] == "no_access"

        respond_to do |format|
          format.html do
            flash[:notice] = _("User details were updated successfully.")
            redirect_to [:backend, current_inventory_pool, @user].compact
          end
          format.json do
            with = {:access_right => true}
            flash[:notice] = _("User details were updated successfully.")
            render json: view_context.hash_for(@user, with.merge({:preset => :user}))
          end
        end
      end
    rescue => e
      respond_to do |format|
        format.html do
          flash.now[:error] = e.to_s
          render action: :edit_in_inventory_pool
        end
        format.json { render :text => e.to_s, :status => 500 }
      end
    end
  end

  def destroy
    not_authorized! unless is_admin?
    respond_to do |format|
      format.json {
        @user.destroy if @user.deletable?
        if @user.persisted?
          render json: {}, status: :bad_request
        else
          render json: {}, status: :ok
        end
      }
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

# OPTIMIZE
  def things_to_return
    @user_things_to_return = @user.things_to_return
  end

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

  def remind
    if @user.remind(current_user)
      respond_to do |format|
        format.json { render :json => true, :status => 200 }
      end
    else
      respond_to do |format|
        format.json { render :text => @user.errors, :status => 500 }
      end
    end
  end

  def new_contract
    redirect_to [:backend, current_inventory_pool, @user, :hand_over]
  end

  def get_accessible_roles_for_current_user

    accessible_roles = [[_("No access"), "no_access"], [_("Customer"), "customer"]]
    accessible_roles +
      if @current_user.has_role? "admin"
        [[_("Lending manager"), "lending_manager"], [_("Inventory manager"), "inventory_manager"]]
      elsif @current_user.has_at_least_access_level 3, @current_inventory_pool
        [[_("Lending manager"), "lending_manager"]]
      else [] end

  end
end
