class Backend::UsersController < Backend::BackendController

  before_filter do
    unless current_inventory_pool
      not_authorized! unless is_admin?
    else
      not_authorized! unless is_lending_manager? or is_admin?
    end

    params[:id] ||= params[:user_id] if params[:user_id]
#    @user = current_inventory_pool.users.find(params[:id]) if params[:id]
    @user = User.find(params[:id]) if params[:id]
  end

######################################################################

  def index(page = (params[:page] || 1).to_i,
      per_page = (params[:per_page] || PER_PAGE).to_i,
      search = params[:search],
      role = params[:role],
      suspended = (params[:suspended] == "true"),
      with = params[:with] ? params[:with].deep_symbolize_keys : {})
    respond_to do |format|
      format.html
      format.json {
        users = case role
                  when "admins"
                    User.admins
                  when "unknown"
                    User.unknown_for(current_inventory_pool)
                  when "customers", "lending_managers", "inventory_managers"
                    current_inventory_pool.send(suspended ? :suspended_users : :users).send(role)
                  else
                    User.scoped
                end.search(search).order("users.updated_at DESC").paginate(:page => page, :per_page => per_page)

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
  end

  def create
    @user = User.new(params[:user])
    @user.login = @user.email
    if @user.save
      @user.access_rights.create(:inventory_pool => current_inventory_pool,
                                 :role => Role.where(:name => "customer").first) if current_inventory_pool
      redirect_to [:backend, current_inventory_pool, @user].compact
    else
      flash[:error] = @user.errors.full_messages.uniq
      render :action => :new
    end
  end

  def edit
  end

  def update
    if params[:access_right]
      ip_id = if params[:access_right][:inventory_pool_id] and is_admin?
                params[:access_right][:inventory_pool_id]
              else
                current_inventory_pool.id
              end
      access_right = @user.all_access_rights.find_or_initialize_by_inventory_pool_id(ip_id)
      access_right.suspended_until, access_right.suspended_reason = if params[:access_right][:suspended_until].blank?
        [nil, nil]
      else
        [params[:access_right][:suspended_until], params[:access_right][:suspended_reason]]
      end
      access_right.role_name = params[:access_right][:role_name] unless params[:access_right][:role_name].blank?
      access_right.save # TODO what if not saved ??
    end

    if params[:user] and params[:user].has_key?(:groups) and (groups = params[:user].delete(:groups))
      @user.groups = groups.map {|g| Group.find g["id"]}
      @user.save
    end

    if @user.update_attributes(params[:user])
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
      respond_to do |format|
        format.html {
          flash[:error] = _("The new user details could not be saved.")
          redirect_to [:edit, :backend, current_inventory_pool, @user].compact
        }
        format.json { render :text => @user.errors, :status => 500 }
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


end
