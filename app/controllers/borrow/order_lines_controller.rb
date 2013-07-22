class Borrow::OrderLinesController < Borrow::ApplicationController

  def create(model = current_user.models.borrowable.find(params[:model_id]),
             quantity = (params[:quantity] || 1).to_i,
             start_date = params[:start_date].try{|x| Date.parse(x)} || Date.today,
             end_date = params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow,
             inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id]))
    
    current_order.errors.add(:base, _("Inventory pool is closed on start date")) unless inventory_pool.is_open_on?(start_date)
    current_order.errors.add(:base, _("Inventory pool is closed on end date")) unless inventory_pool.is_open_on?(end_date)
    unless model.availability_in(inventory_pool).maximum_available_in_period_for_groups(start_date, end_date, current_user.group_ids) >= quantity
      current_order.errors.add(:base, _("Item is not available in that time range"))
    end
    
    if not current_order.errors.any? and
       lines = model.add_to_document(current_order, current_user.id, quantity, start_date, end_date, inventory_pool) and
       current_order.save
      render :status => :ok, :json => lines
    else
      render :status => :bad_request, :json => current_order.errors.full_messages.uniq.join(", ")
    end
  end

end