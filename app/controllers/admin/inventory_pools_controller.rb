class Admin::InventoryPoolsController < Admin::ApplicationController
  
  def index
    @inventory_pools = InventoryPool.all.sort
  end

  def new
    @inventory_pool = InventoryPool.new
  end

  def create
    @inventory_pool = InventoryPool.new
    process_params params[:inventory_pool]

    if @inventory_pool.update_attributes(params[:inventory_pool])
      inventory_managers_access_rights
      flash[:notice] = _('Inventory pool successfully created')
      redirect_to admin_inventory_pools_path
    else
      flash.now[:error] = @inventory_pool.errors.full_messages.uniq.join(', ')
      render :new
    end
  end

  def edit
    @inventory_pool = InventoryPool.find(params[:id])
  end

  def update
    @inventory_pool = InventoryPool.find(params[:id])
    process_params params[:inventory_pool]

    if @inventory_pool.update_attributes(params[:inventory_pool])
      inventory_managers_access_rights
      flash[:notice] = _('Inventory pool successfully updated')
      redirect_to admin_edit_inventory_pool_path(@inventory_pool)
    else
      flash.now[:error] = @inventory_pool.errors.full_messages.uniq.join(', ')
      render :edit
    end
  end

  def destroy
    begin
      InventoryPool.find(params[:id]).destroy
      respond_to do |format|
        format.json { render status: :no_content, nothing: true }
        format.html { redirect_to action: :index, flash: { success: _('%s successfully deleted') % _('Inventory Pool') }}
      end
    rescue => e
      respond_to do |format|
        format.json { render status: :bad_request, nothing: true }
        format.html { redirect_to action: :index, flash: { error: e }}
      end
    end
  end

  private

  def process_params ip
    ip[:email] = nil if params[:inventory_pool][:email].blank?
  end

  def inventory_managers_access_rights
    existing_inventory_manager_ids = @inventory_pool.users.inventory_managers.pluck(:id).sort
    submitted_inventory_manager_ids = if params[:inventory_managers]
                                        params[:inventory_managers][:users].map {|h| h[:id].to_i }.sort
                                      else
                                        []
                                      end
    to_delete = existing_inventory_manager_ids - submitted_inventory_manager_ids
    to_delete.each do |id|
      user = User.find id
      ar = user.access_right_for(@inventory_pool)
      ar.update_attributes! role: :customer
    end
    to_add = submitted_inventory_manager_ids - existing_inventory_manager_ids
    to_add.each do |id|
      user = User.find id
      ar = user.access_right_for(@inventory_pool) || user.access_rights.build(inventory_pool: @inventory_pool)
      ar.update_attributes! role: :inventory_manager
    end
  end

end
