class Manage::SuppliersController < Manage::ApplicationController

  before_action only: [:show, :update, :destroy] do
    @supplier = Supplier.find(params[:id])
  end

  def index
    @suppliers = current_inventory_pool.suppliers.filter(params)
  end

  def show
    @items = @supplier.items.where("#{current_inventory_pool.id} IN (inventory_pool_id, owner_id)").includes(:model, :inventory_pool)
  end

  def destroy
    begin
      @supplier.destroy
      flash[:success] = _('%s successfully deleted') % _('Supplier')
    rescue => e
      flash[:error] = e.to_s
    end
    redirect_to action: :index
  end

end
  
