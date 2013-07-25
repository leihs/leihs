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
        render json: view_context.hash_for(@user, {:access_right => true, :preset => :user, :groups => true})
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
    @user = User.new(params[:user])
    @user.login = @user.email if @user.email

    if @user.save
      @user.all_access_rights.create(role_name: "admin") if should_be_admin == "true"

      flash[:notice] = _("User created successfully")
      redirect_to backend_users_path
    else
      @user.errors.delete(:login) if @user.errors.has_key? :email
      flash.now[:error] = @user.errors.full_messages.uniq
      @is_admin = should_be_admin
      render action: :new
    end
  end

  def create_in_inventory_pool
    groups = params[:user].delete(:groups) if params[:user].has_key?(:groups)
    @user = User.new(params[:user])
    @user.login = @user.email if @user.email
    @user.groups = groups.map {|g| Group.find g["id"]} if groups

    if @user.save
      @user.access_rights.create inventory_pool: @current_inventory_pool, role_name: params[:access_right][:role_name] unless params[:access_right][:role_name] == "no_access"

      flash[:notice] = _("User created successfully")
      redirect_to backend_inventory_pool_users_path(@current_inventory_pool)

    else
      @user.errors.delete(:login) if @user.errors.has_key? :email
      flash.now[:error] = @user.errors.full_messages.uniq
      @accessible_roles = get_accessible_roles_for_current_user
      render action: :new_in_inventory_pool
    end

  end

  def edit
    @is_admin = @user.has_role? "admin"
  end

  def edit_in_inventory_pool
  end

  def update

    should_be_admin = params[:user].delete(:admin)

    if @user.update_attributes(params[:user])

      @user.all_access_rights.delete_all {|ar| ar.role_name == "admin"}
      @user.all_access_rights.create(role_name: "admin") if should_be_admin == "true"

      respond_to do |format|
        format.html {
          flash[:notice] = _("User details were updated successfully.")
          redirect_to backend_users_path
        }
      end

    else
      respond_to do |format|
        format.html {
          @user.errors.delete(:login) if @user.errors.has_key? :email
          flash.now[:error] = @user.errors.full_messages.uniq
          @is_admin = should_be_admin
          render action: :edit
        }
      end
    end

  end

  def update_in_inventory_pool

    if params[:user] and params[:user].has_key?(:groups) and (groups = params[:user].delete(:groups))
      @user.groups = groups.map {|g| Group.find g["id"]}
    end

    @access_right = @user.all_access_rights.find_or_initialize_by_inventory_pool_id(@ip_id)
    @access_right.suspended_until, @access_right.suspended_reason = if params[:access_right][:suspended_until].blank?
                                                                      [nil, nil]
                                                                    else
                                                                      [params[:access_right][:suspended_until], params[:access_right][:suspended_reason]]
                                                                    end
    @access_right.role_name = params[:access_right][:role_name] unless params[:access_right][:role_name].blank?

    if @access_right.save and @user.update_attributes(params[:user])

      respond_to do |format|
        format.html {
          flash[:notice] = _("User details were updated successfully.")
          redirect_to [:backend, current_inventory_pool, @user].compact
        }
        format.json {
          with = {:access_right => true}
          render json: view_context.hash_for(@user, with.merge({:preset => :user}))
        }
      end

    else
      @user.errors.delete(:login) if @user.errors.has_key? :email
      errors = @access_right.errors.full_messages.uniq + @user.errors.full_messages.uniq
      respond_to do |format|
        format.html {
          flash.now[:error] = errors
          render action: :edit_in_inventory_pool
        }
        format.json { render :text => errors.join(", "), :status => 500 }
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
