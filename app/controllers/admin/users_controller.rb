class Admin::UsersController < Admin::ApplicationController

  before_filter only: [:edit, :update, :destroy] do
    #@user = current_inventory_pool.users.find(params[:id])
    @user = User.find(params[:id])
  end

######################################################################

  def index
    @role = params[:role]
    @users = User.filter params, current_inventory_pool
    set_pagination_header @users unless params[:paginate] == 'false'
  end

  def new
    @delegation_type = true if params[:type] == 'delegation'
    @user = User.new
    @is_admin = false unless @delegation_type
  end

  def create
    should_be_admin = params[:user].delete(:admin)
    if users = params[:user].delete(:users)
      delegated_user_ids = users.map {|h| h['id']}
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

        @user.access_rights.create!(role: :admin) if should_be_admin == 'true'

        respond_to do |format|
          format.html do
            flash[:notice] = _('User created successfully')
            redirect_to admin_users_path
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

  def edit
    @is_admin = @user.has_role? :admin
    @db_auth = DatabaseAuthentication.find_by_user_id(@user.id)
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
        @user.access_rights.create!(role: :admin) if should_be_admin == 'true'

        respond_to do |format|
          format.html do
            flash[:notice] = _('User details were updated successfully.')
            redirect_to admin_users_path
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

  def destroy
    @user.destroy if @user.deletable?
    respond_to do |format|
      format.json{ @user.persisted? ? render(status: :bad_request) : head(status: :ok)}
      format.html do 
        if @user.persisted? 
          redirect_to(:back, flash: {error: _('You cannot delete this user')})
        else 
          redirect_to(:back, flash: {success: _('%s successfully deleted') % _('User')})
        end 
      end
    end
  end

#################################################################

  def get_accessible_roles_for_current_user
    accessible_roles = [[_('No access'), :no_access], [_('Customer'), :customer]]
    unless @delegation_type
      accessible_roles +=
        if @current_user.has_role? :admin or @current_user.has_role? :inventory_manager, @current_inventory_pool
          [[_('Group manager'), :group_manager], [_('Lending manager'), :lending_manager], [_('Inventory manager'), :inventory_manager]]
        elsif @current_user.has_role? :lending_manager, @current_inventory_pool
          [[_('Group manager'), :group_manager], [_('Lending manager'), :lending_manager]]
        else
          []
        end
    end
    accessible_roles
  end

  private

  def get_delegated_users_ids params
    # for complete users replacement, get only user ids without the _destroy flag
    if users = params[:user].delete(:users)
      users.select{|h| h['_destroy'] != '1'}.map {|h| h['id']}
    end
  end

end
