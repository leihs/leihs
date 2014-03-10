class Manage::AvailabilityController < Manage::ApplicationController

  before_filter do 
    @models = Model.where :id => params[:model_ids]
    render :status => :bad_request, :nothing => true and return if @models.blank?
    @availabilities = []
  end

  def index
    user = current_inventory_pool.users.find params[:user_id]
    @models.each do |model|
      @availabilities.push({
        id: "#{model.id}-#{user.id}-#{current_inventory_pool.id}",
        changes: model.availability_in(current_inventory_pool).available_total_quantities,
        total_rentable: model.items.where(inventory_pool_id: current_inventory_pool).borrowable.count,
        inventory_pool_id: current_inventory_pool.id,
        model_id: model.id
      })
    end
  end

  def in_stock
    @models.each do |model|
      @availabilities.push({
        id: "#{model.id}-#{current_inventory_pool.id}",
        total_rentable: model.items.where(inventory_pool_id: current_inventory_pool).borrowable.count,
        in_stock: model.items.where(inventory_pool_id: current_inventory_pool).borrowable.in_stock.count,
        inventory_pool_id: current_inventory_pool.id,
        model_id: model.id
      })
    end
    render :index
  end

end
