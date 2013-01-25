class Backend::UsersController < Backend::BackendController

  before_filter do
    unless current_inventory_pool
      not_authorized! unless is_admin?
    else
      not_authorized! unless is_lending_manager?
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
        render json: view_context.hash_for(@user, {:access_right => true, :preset => :user})
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
      access_right = @user.access_rights.find_or_initialize_by_inventory_pool_id(current_inventory_pool.id)
      new_attributes = if params[:access_right][:suspended_until].blank?
                         {:suspended_until => nil, :suspended_reason => nil}
                       else
                         {:suspended_until => params[:access_right][:suspended_until], :suspended_reason => params[:access_right][:suspended_reason]}
                       end
      unless params[:access_right][:role_name].blank?
        new_attributes[:role_name] = params[:access_right][:role_name]
      end
      access_right.update_attributes(new_attributes)
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

#################################################################

=begin
  #old leihs#
  def access_rights
    @access_rights = if current_inventory_pool
                       @user.access_rights.scoped_by_inventory_pool_id(current_inventory_pool)
                     else
                       @user.access_rights.includes(:inventory_pool).order("inventory_pools.name")
                     end
  end

  #old leihs#
  def add_access_right
    inventory_pool_id = if current_inventory_pool
                          current_inventory_pool.id
                        else
                          params[:access_right][:inventory_pool_id]
                        end

    r = Role.find(params[:access_right][:role_id]) if params[:access_right]
    r ||= Role.find_by_name("customer") # OPTIMIZE

    ar = @user.all_access_rights.where(:inventory_pool_id => inventory_pool_id).first

    if ar
      ar.update_attributes(:role => r, :access_level => params[:access_level])
      ar.update_attributes(:deleted_at => nil) if ar.deleted_at
      flash[:notice] = _("Access Right successfully updated")
    else
      ar = @user.access_rights.create(:role => r, :inventory_pool_id => inventory_pool_id, :access_level => params[:access_level])
      flash[:notice] = _("Access Right successfully created")
    end

    unless ar.valid?
      flash[:notice] = nil
      flash[:error] = ar.errors.full_messages.uniq
    end
    redirect_to url_for([:access_rights, :backend, current_inventory_pool, @user].compact)
  end

  #old leihs#
  def remove_access_right
    ar = @user.access_rights.find(params[:access_right_id])
    if ar.inventory_pool_id.nil? or ar.inventory_pool.contract_lines.by_user(@user).to_take_back.empty?
      ar.deactivate
    else
      flash[:error] = _("Currently has things to return")
    end
    redirect_to url_for([:access_rights, :backend, current_inventory_pool, @user].compact)
  end
=end

end
